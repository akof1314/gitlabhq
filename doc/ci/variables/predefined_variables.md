---
type: reference
---

# Predefined environment variables reference

For an introduction on this subject, read through the
[getting started with environment variables](README.md) document.

## Overview

Some of the predefined environment variables are available only if a minimum
version of [GitLab Runner](https://docs.gitlab.com/runner/) is used. Consult the table below to find the
version of Runner required.

NOTE: **Note:**
Starting with GitLab 9.0, we have deprecated some variables. Read the
[9.0 Renaming](deprecated_variables.md#gitlab-90-renamed-variables) section to find out their replacements. **You are
strongly advised to use the new variables as we will remove the old ones in
future GitLab releases.**

## Variables reference

| Variable                                  | GitLab | Runner | Description |
|-------------------------------------------|--------|--------|-------------|
| `ARTIFACT_DOWNLOAD_ATTEMPTS`            | 8.15   | 1.9    | Number of attempts to download artifacts running a job |
| `CHAT_INPUT`                            | 10.6   | all    | Additional arguments passed in the [ChatOps](../chatops/README.md) command |
| `CHAT_CHANNEL`                          | 10.6   | all    | Source chat channel which triggered the [ChatOps](../chatops/README.md) command |
| `CI`                                    | all    | 0.4    | Mark that job is executed in CI environment |
| `CI_BUILDS_DIR`                         | all    | 11.10  | Top-level directory where builds are executed. |
| `CI_CONCURRENT_ID`                      | all    | 11.10  | Unique ID of build execution within a single executor. |
| `CI_CONCURRENT_PROJECT_ID`              | all    | 11.10  | Unique ID of build execution within a single executor and project. |
| `CI_COMMIT_BEFORE_SHA`                  | 11.2   | all    | The previous latest commit present on a branch before a push request. Only populated when there is a merge request associated with the pipeline. |
| `CI_COMMIT_DESCRIPTION`                 | 10.8   | all    | The description of the commit: the message without first line, if the title is shorter than 100 characters; full message in other case. |
| `CI_COMMIT_MESSAGE`                     | 10.8   | all    | The full commit message. |
| `CI_COMMIT_REF_NAME`                    | 9.0    | all    | The branch or tag name for which project is built |
| `CI_COMMIT_REF_SLUG`                    | 9.0    | all    | `$CI_COMMIT_REF_NAME` lowercased, shortened to 63 bytes, and with everything except `0-9` and `a-z` replaced with `-`. No leading / trailing `-`. Use in URLs, host names and domain names. |
| `CI_COMMIT_SHA`                         | 9.0    | all    | The commit revision for which project is built |
| `CI_COMMIT_SHORT_SHA`                   | 11.7   | all    | The first eight characters of `CI_COMMIT_SHA` |
| `CI_COMMIT_TAG`                         | 9.0    | 0.5    | The commit tag name. Present only when building tags. |
| `CI_COMMIT_TITLE`                       | 10.8   | all    | The title of the commit - the full first line of the message |
| `CI_CONFIG_PATH`                        | 9.4    | 0.5    | The path to CI config file. Defaults to `.gitlab-ci.yml` |
| `CI_DEBUG_TRACE`                        | all    | 1.7    | Whether [debug tracing](README.md#debug-tracing) is enabled |
| `CI_DEPLOY_PASSWORD`                    | 10.8   | all    | Authentication password of the [GitLab Deploy Token][gitlab-deploy-token], only present if the Project has one related.|
| `CI_DEPLOY_USER`                        | 10.8   | all    | Authentication username of the [GitLab Deploy Token][gitlab-deploy-token], only present if the Project has one related.|
| `CI_DISPOSABLE_ENVIRONMENT`             | all    | 10.1   | Marks that the job is executed in a disposable environment (something that is created only for this job and disposed of/destroyed after the execution - all executors except `shell` and `ssh`). If the environment is disposable, it is set to true, otherwise it is not defined at all. |
| `CI_ENVIRONMENT_NAME`                   | 8.15   | all    | The name of the environment for this job. Only present if [`environment:name`](../yaml/README.md#environmentname) is set. |
| `CI_ENVIRONMENT_SLUG`                   | 8.15   | all    | A simplified version of the environment name, suitable for inclusion in DNS, URLs, Kubernetes labels, etc. Only present if [`environment:name`](../yaml/README.md#environmentname) is set. |
| `CI_ENVIRONMENT_URL`                    | 9.3    | all    | The URL of the environment for this job. Only present if [`environment:url`](../yaml/README.md#environmenturl) is set. |
| `CI_JOB_ID`                             | 9.0    | all    | The unique id of the current job that GitLab CI uses internally |
| `CI_JOB_MANUAL`                         | 8.12   | all    | The flag to indicate that job was manually started |
| `CI_JOB_NAME`                           | 9.0    | 0.5    | The name of the job as defined in `.gitlab-ci.yml` |
| `CI_JOB_STAGE`                          | 9.0    | 0.5    | The name of the stage as defined in `.gitlab-ci.yml` |
| `CI_JOB_TOKEN`                          | 9.0    | 1.2    | Token used for authenticating with the [GitLab Container Registry][registry] and downloading [dependent repositories][dependent-repositories] |
| `CI_JOB_URL`                            | 11.1   | 0.5    | Job details URL |
| `CI_MERGE_REQUEST_ID`                   | 11.6   | all    | The ID of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created. |
| `CI_MERGE_REQUEST_IID`                  | 11.6   | all    | The IID of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_PROJECT_ID`           | 11.6   | all    | The ID of the project of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_PROJECT_PATH`         | 11.6   | all    | The path of the project of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md) (e.g. `namespace/awesome-project`). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_PROJECT_URL`          | 11.6   | all    | The URL of the project of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md) (e.g. `http://192.168.10.15:3000/namespace/awesome-project`). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_REF_PATH`             | 11.6   | all    | The ref path of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). (e.g. `refs/merge-requests/1/head`). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_SOURCE_BRANCH_NAME`   | 11.6   | all    | The source branch name of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_SOURCE_BRANCH_SHA`    | 11.9   | all    | The HEAD sha of the source branch of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_SOURCE_PROJECT_ID`    | 11.6   | all    | The ID of the source project of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_SOURCE_PROJECT_PATH`  | 11.6   | all    | The path of the source project of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_SOURCE_PROJECT_URL`   | 11.6   | all    | The URL of the source project of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_TARGET_BRANCH_NAME`   | 11.6   | all    | The target branch name of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_TARGET_BRANCH_SHA`    | 11.9   | all    | The HEAD sha of the target branch of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_TITLE`                | 11.9   | all    | The title of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_ASSIGNEES`            | 11.9   | all    | Comma-separated list of username(s) of assignee(s) for the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created. |
| `CI_MERGE_REQUEST_MILESTONE`            | 11.9   | all    | The milestone title of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_MERGE_REQUEST_LABELS`               | 11.9   | all    | Comma-separated label names of the merge request if [the pipelines are for merge requests](../merge_request_pipelines/index.md). Available only if `only: [merge_requests]` is used and the merge request is created.  |
| `CI_NODE_INDEX`                         | 11.5   | all    | Index of the job in the job set. If the job is not parallelized, this variable is not set. |
| `CI_NODE_TOTAL`                         | 11.5   | all    | Total number of instances of this job running in parallel. If the job is not parallelized, this variable is set to `1`. |
| `CI_API_V4_URL`                         | 11.7   | all    | The GitLab API v4 root URL |
| `CI_PAGES_DOMAIN`                       | 11.8   | all    | The configured domain that hosts GitLab Pages. |
| `CI_PAGES_URL`                          | 11.8   | all    | URL to GitLab Pages-built pages. Always belongs to a subdomain of `CI_PAGES_DOMAIN`. |
| `CI_PIPELINE_ID`                        | 8.10   | all    | The unique id of the current pipeline that GitLab CI uses internally |
| `CI_PIPELINE_IID`                       | 11.0   | all    | The unique id of the current pipeline scoped to project |
| `CI_PIPELINE_SOURCE`                    | 10.0   | all    | Indicates how the pipeline was triggered. Possible options are: `push`, `web`, `trigger`, `schedule`, `api`, and `pipeline`. For pipelines created before GitLab 9.5, this will show as `unknown` |
| `CI_PIPELINE_TRIGGERED`                 | all    | all    | The flag to indicate that job was [triggered](../triggers/README.md) |
| `CI_PIPELINE_URL`                       | 11.1   | 0.5    | Pipeline details URL |
| `CI_PROJECT_DIR`                        | all    | all    | The full path where the repository is cloned and where the job is run. If the GitLab Runner `builds_dir` parameter is set, this variable is set relative to the value of `builds_dir`. For more information, see [Advanced configuration](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runners-section) for GitLab Runner. |
| `CI_PROJECT_ID`                         | all    | all    | The unique id of the current project that GitLab CI uses internally |
| `CI_PROJECT_NAME`                       | 8.10   | 0.5    | The project name that is currently being built (actually it is project folder name) |
| `CI_PROJECT_NAMESPACE`                  | 8.10   | 0.5    | The project namespace (username or groupname) that is currently being built |
| `CI_PROJECT_PATH`                       | 8.10   | 0.5    | The namespace with project name |
| `CI_PROJECT_PATH_SLUG`                  | 9.3    | all    | `$CI_PROJECT_PATH` lowercased and with everything except `0-9` and `a-z` replaced with `-`. Use in URLs and domain names. |
| `CI_PROJECT_URL`                        | 8.10   | 0.5    | The HTTP(S) address to access project |
| `CI_PROJECT_VISIBILITY`                 | 10.3   | all    | The project visibility (internal, private, public) |
| `CI_COMMIT_REF_PROTECTED`                      | 11.11  | all    | If the job is running on a protected branch |
| `CI_REGISTRY`                           | 8.10   | 0.5    | If the Container Registry is enabled it returns the address of GitLab's Container Registry |
| `CI_REGISTRY_IMAGE`                     | 8.10   | 0.5    | If the Container Registry is enabled for the project it returns the address of the registry tied to the specific project |
| `CI_REGISTRY_PASSWORD`                  | 9.0    | all    | The password to use to push containers to the GitLab Container Registry |
| `CI_REGISTRY_USER`                      | 9.0    | all    | The username to use to push containers to the GitLab Container Registry |
| `CI_REPOSITORY_URL`                     | 9.0    | all    | The URL to clone the Git repository |
| `CI_RUNNER_DESCRIPTION`                 | 8.10   | 0.5    | The description of the runner as saved in GitLab |
| `CI_RUNNER_EXECUTABLE_ARCH`             | all    | 10.6   | The OS/architecture of the GitLab Runner executable (note that this is not necessarily the same as the environment of the executor) |
| `CI_RUNNER_ID`                          | 8.10   | 0.5    | The unique id of runner being used |
| `CI_RUNNER_REVISION`                    | all    | 10.6   | GitLab Runner revision that is executing the current job |
| `CI_RUNNER_TAGS`                        | 8.10   | 0.5    | The defined runner tags |
| `CI_RUNNER_VERSION`                     | all    | 10.6   | GitLab Runner version that is executing the current job |
| `CI_SERVER`                             | all    | all    | Mark that job is executed in CI environment |
| `CI_SERVER_NAME`                        | all    | all    | The name of CI server that is used to coordinate jobs |
| `CI_SERVER_REVISION`                    | all    | all    | GitLab revision that is used to schedule jobs |
| `CI_SERVER_VERSION`                     | all    | all    | GitLab version that is used to schedule jobs |
| `CI_SERVER_VERSION_MAJOR`               | 11.4   | all    | GitLab version major component |
| `CI_SERVER_VERSION_MINOR`               | 11.4   | all    | GitLab version minor component |
| `CI_SERVER_VERSION_PATCH`               | 11.4   | all    | GitLab version patch component |
| `CI_SHARED_ENVIRONMENT`                 | all    | 10.1   | Marks that the job is executed in a shared environment (something that is persisted across CI invocations like `shell` or `ssh` executor). If the environment is shared, it is set to true, otherwise it is not defined at all. |
| `GET_SOURCES_ATTEMPTS`                  | 8.15   | 1.9    | Number of attempts to fetch sources running a job |
| `GITLAB_CI`                             | all    | all    | Mark that job is executed in GitLab CI environment |
| `GITLAB_USER_EMAIL`                     | 8.12   | all    | The email of the user who started the job |
| `GITLAB_USER_ID`                        | 8.12   | all    | The id of the user who started the job |
| `GITLAB_USER_LOGIN`                     | 10.0   | all    | The login username of the user who started the job |
| `GITLAB_USER_NAME`                      | 10.0   | all    | The real name of the user who started the job |
| `RESTORE_CACHE_ATTEMPTS`                | 8.15   | 1.9    | Number of attempts to restore the cache running a job |
| `GITLAB_FEATURES`                       | 10.6   | all    | The comma separated list of licensed features available for your instance and plan |

[gitlab-deploy-token]: ../../user/project/deploy_tokens/index.md#gitlab-deploy-token
[registry]: ../../user/project/container_registry.md
[dependent-repositories]: ../../user/project/new_ci_build_permissions_model.md#dependent-repositories
