---
type: reference
---

# Continuous Integration and Deployment Admin settings **(CORE ONLY)**

In this area, you will find settings for Auto DevOps, Runners and job artifacts.
You can find it in the admin area, under **Settings > Continuous Integration and Deployment**.

![Admin area settings button](../img/admin_area_settings_button.png)

## Auto DevOps **(CORE ONLY)**

To enable (or disable) [Auto DevOps](../../../topics/autodevops/index.md)
for all projects:

1. Go to **Admin area > Settings > Continuous Integration and Deployment**
1. Check (or uncheck to disable) the box that says "Default to Auto DevOps pipeline for all projects"
1. Optionally, set up the [Auto DevOps base domain](../../../topics/autodevops/index.md#auto-devops-base-domain)
   which is going to be used for Auto Deploy and Auto Review Apps.
1. Hit **Save changes** for the changes to take effect.

From now on, every existing project and newly created ones that don't have a
`.gitlab-ci.yml`, will use the Auto DevOps pipelines.

If you want to disable it for a specific project, you can do so in
[its settings](../../../topics/autodevops/index.md#enablingdisabling-auto-devops).

## Maximum artifacts size **(CORE ONLY)**

The maximum size of the [job artifacts](../../../administration/job_artifacts.md)
can be set in the Admin area of your GitLab instance. The value is in *MB* and
the default is 100MB per job; on GitLab.com it's [set to 1G](../../gitlab_com/index.md#gitlab-cicd).

To change it:

1. Go to **Admin area > Settings > Continuous Integration and Deployment**.
1. Change the value of maximum artifacts size (in MB).
1. Hit **Save changes** for the changes to take effect.

## Default artifacts expiration **(CORE ONLY)**

The default expiration time of the [job artifacts](../../../administration/job_artifacts.md)
can be set in the Admin area of your GitLab instance. The syntax of duration is
described in [`artifacts:expire_in`](../../../ci/yaml/README.md#artifactsexpire_in)
and the default value is `30 days`. On GitLab.com they
[never expire](../../gitlab_com/index.md#gitlab-cicd).

1. Go to **Admin area > Settings > Continuous Integration and Deployment**.
1. Change the value of default expiration time.
1. Hit **Save changes** for the changes to take effect.

This setting is set per job and can be overridden in
[`.gitlab-ci.yml`](../../../ci/yaml/README.md#artifactsexpire_in).
To disable the expiration, set it to `0`. The default unit is in seconds.

## Shared Runners pipeline minutes quota **(STARTER ONLY)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ee/merge_requests/1078)
in GitLab Starter 8.16.

If you have enabled shared Runners for your GitLab instance, you can limit their
usage by setting a maximum number of pipeline minutes that a group can use on
shared Runners per month. Setting this to `0` (default value) will grant
unlimited pipeline minutes. While build limits are stored as minutes, the
counting is done in seconds. Usage resets on the first day of each month.
On GitLab.com, the quota is calculated based on your
[subscription plan](https://about.gitlab.com/pricing/#gitlab-com).

To change the pipelines minutes quota:

1. Go to **Admin area > Settings > Continuous Integration and Deployment**
1. Set the pipeline minutes quota limit.
1. Hit **Save changes** for the changes to take effect

---

While the setting in the Admin area has a global effect, as an admin you can
also change each group's pipeline minutes quota to override the global value.

1. Navigate to the **Groups** admin area and hit the **Edit** button for the
   group you wish to change the pipeline minutes quota.
1. Set the pipeline minutes quota to the desired value
1. Hit **Save changes** for the changes to take effect.

Once saved, you can see the build quota in the group admin view.
The quota can also be viewed in the project admin view if shared Runners
are enabled.

![Project admin info](img/admin_project_quota_view.png)

You can see an overview of the pipeline minutes quota of all projects of
a group in the **Usage Quotas** page available to the group page settings list.

![Group pipelines quota](img/group_pipelines_quota.png)

## Extra Shared Runners pipeline minutes quota **[FREE ONLY]**

If you're using GitLab.com, you can purchase additional CI minutes so your
pipelines will not be blocked after you have used all your CI minutes from your
main quota.

In order to purchase additional minutes, you should follow these steps:

1. Go to **Group > Settings > Pipelines quota**. Once you are on that page, click on **Buy additional minutes**.

    ![Buy additional minutes](img/buy_btn.png)

1. Locate the subscription card that is linked to your group on GitLab.com,
   click on **Buy more CI minutes**, and complete the details about the transaction.

    ![Buy additional minutes](img/buy_minutes_card.png)

1. Once we have processed your payment, the extra CI minutes
   will be synced to your Group and you can visualize it from  the
   **Group > Settings > Pipelines quota** page:

    ![Additional minutes](img/additional_minutes.png)

Be aware that:

1. If you have purchased extra CI minutes before the purchase of a paid plan,
   we will calculate a pro-rated charge for your paid plan. That means you may
   be charged for less than one year since your subscription was previously
   created with the extra CI minutes.
1. Once the extra CI minutes has been assigned to a Group they cannot be transferred
   to a different Group.
1. If you have some minutes used over your default quota, these minutes will
   be deducted from your Additional Minutes quota immediately after your purchase of additional
   minutes.

## What happens when my CI minutes quota run out

When the CI minutes quota run out, an email is sent automatically to notifies the owner(s) of the group/namespace which
includes a link to [purchase more minutes](https://customers.gitlab.com/plans).

If you are not the owner of the group, you will need to contact them to let them know they need to
[purchase more minutes](https://customers.gitlab.com/plans).

## Archive jobs **(CORE ONLY)**

Archiving jobs is useful for reducing the CI/CD footprint on the system by
removing some of the capabilities of the jobs (metadata needed to run the job),
but persisting the traces and artifacts for auditing purposes.

To set the duration for which the jobs will be considered as old and expired:

1. Go to **Admin area > Settings > CI/CD > Continuous Integration and Deployment**.
1. Change the value of "Archive jobs".
1. Hit **Save changes** for the changes to take effect.

Once that time passes, the jobs will be archived and no longer able to be
retried. Make it empty to never expire jobs. It has to be no less than 1 day,
for example: <code>15 days</code>, <code>1 month</code>, <code>2 years</code>.

<!-- ## Troubleshooting

Include any troubleshooting steps that you can foresee. If you know beforehand what issues
one might have when setting this up, or when something is changed, or on upgrading, it's
important to describe those, too. Think of things that may go wrong and include them here.
This is important to minimize requests for support, and to avoid doc comments with
questions that you know someone might ask.

Each scenario can be a third-level heading, e.g. `### Getting error message X`.
If you have none to add when creating a doc, leave this section in place
but commented out to help encourage others to add to it in the future. -->
