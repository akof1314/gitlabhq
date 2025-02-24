# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'tempfile'

describe Gitlab::Git::RuggedImpl::UseRugged, :seed_helper do
  let(:project) { create(:project, :repository) }
  let(:repository) { project.repository }
  let(:feature_flag_name) { 'feature-flag-name' }
  let(:feature_flag) { Feature.get(feature_flag_name) }
  let(:temp_gitaly_metadata_file) { create_temporary_gitaly_metadata_file }

  before(:all) do
    create_gitaly_metadata_file
  end

  subject(:wrapper) do
    klazz = Class.new { include Gitlab::Git::RuggedImpl::UseRugged }
    klazz.new
  end

  before do
    Gitlab::GitalyClient.instance_variable_set(:@can_use_disk, {})
  end

  context 'when feature flag is not persisted' do
    before do
      allow(Feature).to receive(:persisted?).with(feature_flag).and_return(false)
    end

    it 'returns true when gitaly matches disk' do
      pending('temporary disabled because of https://gitlab.com/gitlab-org/gitlab-ce/issues/64338')
      expect(subject.use_rugged?(repository, feature_flag_name)).to be true
    end

    it 'returns false when disk access fails' do
      allow(Gitlab::GitalyClient).to receive(:storage_metadata_file_path).and_return("/fake/path/doesnt/exist")

      expect(subject.use_rugged?(repository, feature_flag_name)).to be false
    end

    it "returns false when gitaly doesn't match disk" do
      allow(Gitlab::GitalyClient).to receive(:storage_metadata_file_path).and_return(temp_gitaly_metadata_file)

      expect(subject.use_rugged?(repository, feature_flag_name)).to be_falsey

      File.delete(temp_gitaly_metadata_file)
    end

    it "doesn't lead to a second rpc call because gitaly client should use the cached value" do
      pending('temporary disabled because of https://gitlab.com/gitlab-org/gitlab-ce/issues/64338')
      expect(subject.use_rugged?(repository, feature_flag_name)).to be true

      expect(Gitlab::GitalyClient).not_to receive(:filesystem_id)

      subject.use_rugged?(repository, feature_flag_name)
    end
  end

  context 'when feature flag is persisted' do
    before do
      allow(Feature).to receive(:persisted?).with(feature_flag).and_return(true)
    end

    it 'returns false when the feature flag is off' do
      allow(feature_flag).to receive(:enabled?).and_return(false)

      expect(subject.use_rugged?(repository, feature_flag_name)).to be_falsey
    end

    it "returns true when feature flag is on" do
      allow(feature_flag).to receive(:enabled?).and_return(true)
      allow(Gitlab::GitalyClient).to receive(:can_use_disk?).and_return(false)

      expect(subject.use_rugged?(repository, feature_flag_name)).to be true
    end
  end

  def create_temporary_gitaly_metadata_file
    tmp = Tempfile.new('.gitaly-metadata')
    gitaly_metadata = {
      "gitaly_filesystem_id" => "some-value"
    }
    tmp.write(gitaly_metadata.to_json)
    tmp.flush
    tmp.close
    tmp.path
  end

  def create_gitaly_metadata_file
    File.open(File.join(SEED_STORAGE_PATH, '.gitaly-metadata'), 'w+') do |f|
      gitaly_metadata = {
        "gitaly_filesystem_id" => SecureRandom.uuid
      }
      f.write(gitaly_metadata.to_json)
    end
  end
end
