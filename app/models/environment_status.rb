# frozen_string_literal: true

class EnvironmentStatus
  include Gitlab::Utils::StrongMemoize

  attr_reader :project, :environment, :merge_request, :sha

  delegate :id, to: :environment
  delegate :name, to: :environment
  delegate :status, to: :deployment, allow_nil: true
  delegate :deployed_at, to: :deployment, allow_nil: true

  def self.for_merge_request(mr, user)
    build_environments_status(mr, user, mr.actual_head_pipeline)
  end

  def self.after_merge_request(mr, user)
    return [] unless mr.merged?

    build_environments_status(mr, user, mr.merge_pipeline)
  end

  def initialize(project, environment, merge_request, sha)
    @project = project
    @environment = environment
    @merge_request = merge_request
    @sha = sha
  end

  def deployment
    strong_memoize(:deployment) do
      Deployment.where(environment: environment).find_by_sha(sha)
    end
  end

  def has_metrics?
    strong_memoize(:has_metrics) do
      deployment_metrics.has_metrics?
    end
  end

  def changes
    return [] if project.route_map_for(sha).nil?

    changed_files.map { |file| build_change(file) }.compact
  end

  def changed_files
    merge_request.merge_request_diff
      .merge_request_diff_files.where(deleted_file: false)
  end

  private

  PAGE_EXTENSIONS = /\A\.(s?html?|php|asp|cgi|pl)\z/i.freeze

  def deployment_metrics
    @deployment_metrics ||= DeploymentMetrics.new(project, deployment)
  end

  def build_change(file)
    public_path = project.public_path_for_source_path(file.new_path, sha)
    return if public_path.nil?

    ext = File.extname(public_path)
    return if ext.present? && ext !~ PAGE_EXTENSIONS

    {
      path: public_path,
      external_url: environment.external_url_for(file.new_path, sha)
    }
  end

  def self.build_environments_status(mr, user, pipeline)
    return [] unless pipeline

    pipeline.environments.available.map do |environment|
      next unless Ability.allowed?(user, :read_environment, environment)

      EnvironmentStatus.new(pipeline.project, environment, mr, pipeline.sha)
    end.compact
  end
  private_class_method :build_environments_status
end
