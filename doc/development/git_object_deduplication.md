# How Git object deduplication works in GitLab

When a GitLab user [forks a project](../workflow/forking_workflow.md),
GitLab creates a new Project with an associated Git repository that is a
copy of the original project at the time of the fork. If a large project
gets forked often, this can lead to a quick increase in Git repository
storage disk use. To counteract this problem, we are adding Git object
deduplication for forks to GitLab. In this document, we will describe how
GitLab implements Git object deduplication.

## Enabling Git object deduplication via feature flags

As of GitLab 12.0, Git object deduplication in GitLab is still behind a
feature flag. In this document, you can read about the effects of
enabling the feature. Also, note that Git object deduplication is
limited to forks of public projects on hashed repository storage.

You can enable deduplication globally by setting the `object_pools`
feature flag to `true`:

``` {.ruby}
Feature.enable(:object_pools)
```

Or just for forks of a specific project:

``` {.ruby}
fork_parent = Project.find(MY_PROJECT_ID)
Feature.enable(:object_pools, fork_parent)
```

To check if a project uses Git object deduplication, look in a Rails
console if `project.pool_repository` is present.

## Pool repositories

### Understanding Git alternates

At the Git level, we achieve deduplication by using [Git
alternates](https://git-scm.com/docs/gitrepository-layout#gitrepository-layout-objects).
Git alternates is a mechanism that lets a repository borrow objects from
another repository on the same machine.

If we want repository A to borrow from repository B, we first write a
path that resolves to `B.git/objects` in the special file
`A.git/objects/info/alternates`. This establishes the alternates link.
Next, we must perform a Git repack in A. After the repack, any objects
that are duplicated between A and B will get deleted from A. Repository
A is now no longer self-contained, but it still has its own refs and
configuration. Objects in A that are not in B will remain in A. For this
to work, it is of course critical that **no objects ever get deleted from
B** because A might need them.

DANGER: **Danger:**
Do not run `git prune` or `git gc` in pool repositories! This can
cause data loss in "real" repositories that depend on the pool in
question.

The danger lies in `git prune`, and `git gc` calls `git prune`. The
problem is that `git prune`, when running in a pool repository, cannot
reliable decide if an object is no longer needed.

### Git alternates in GitLab: pool repositories

GitLab organizes this object borrowing by creating special **pool
repositories** which are hidden from the user. We then use Git
alternates to let a collection of project repositories borrow from a
single pool repository. We call such a collection of project
repositories a pool. Pools form star-shaped networks of repositories
that borrow from a single pool, which will resemble (but not be
identical to) the fork networks that get formed when users fork
projects.

At the Git level, pool repositories are created and managed using Gitaly
RPC calls. Just like with normal repositories, the authority on which
pool repositories exist, and which repositories borrow from them, lies
at the Rails application level in SQL.

In conclusion, we need three things for effective object deduplication
across a collection of GitLab project repositories at the Git level:

1.  A pool repository must exist.
2.  The participating project repositories must be linked to the pool
    repository via their respective `objects/info/alternates` files.
3.  The pool repository must contain Git object data common to the
    participating project repositories.

### Deduplication factor

The effectiveness of Git object deduplication in GitLab depends on the
amount of overlap between the pool repository and each of its
participants. Each time garbage collection runs on the source project,
Git objects from the source project will get migrated to the pool
repository. One by one, as garbage collection runs, other member
projects will benefit from the new objects that got added to the pool.

## SQL model

As of GitLab 11.8, project repositories in GitLab do not have their own
SQL table. They are indirectly identified by columns on the `projects`
table. In other words, the only way to look up a project repository is to
first look up its project, and then call `project.repository`.

With pool repositories we made a fresh start. These live in their own
`pool_repositories` SQL table. The relations between these two tables
are as follows:

-   a `Project` belongs to at most one `PoolRepository`
    (`project.pool_repository`)
-   as an automatic consequence of the above, a `PoolRepository` has
    many `Project`s
-   a `PoolRepository` has exactly one "source `Project`"
    (`pool.source_project`)

> TODO Fix invalid SQL data for pools created prior to GitLab 11.11
> <https://gitlab.com/gitlab-org/gitaly/issues/1653>.

### Assumptions

-   All repositories in a pool must use [hashed
    storage](../administration/repository_storage_types.md). This is so
    that we don't have to ever worry about updating paths in
    `object/info/alternates` files.
-   All repositories in a pool must be on the same Gitaly storage shard.
    The Git alternates mechanism relies on direct disk access across
    multiple repositories, and we can only assume direct disk access to
    be possible within a Gitaly storage shard.
-   The only two ways to remove a member project from a pool are (1) to
    delete the project or (2) to move the project to another Gitaly
    storage shard.

### Creating pools and pool memberships

-   When a pool gets created, it must have a source project. The initial
    contents of the pool repository are a Git clone of the source
    project repository.
-   The occasion for creating a pool is when an existing eligible
    (public, hashed storage, non-forked) GitLab project gets forked and
    this project does not belong to a pool repository yet. The fork
    parent project becomes the source project of the new pool, and both
    the fork parent and the fork child project become members of the new
    pool.
-   Once project A has become the source project of a pool, all future
    eligible forks of A will become pool members.
-   If the fork source is itself a fork, the resulting repository will
    neither join the repository nor will a new pool repository be
    seeded.

    eg:

    Suppose fork A is part of a pool repository, any forks created off
    of fork A *will not* be a part of the pool repository that fork A is
    a part of.

    Suppose B is a fork of A, and A does not belong to an object pool.
    Now C gets created as a fork of B. C will not be part of a pool
    repository.

> TODO should forks of forks be deduplicated?
> <https://gitlab.com/gitlab-org/gitaly/issues/1532>

### Consequences

-   If a normal Project participating in a pool gets moved to another
    Gitaly storage shard, its "belongs to PoolRepository" relation will
    be broken. Because of the way moving repositories between shard is
    implemented, we will automatically get a fresh self-contained copy
    of the project's repository on the new storage shard.
-   If the source project of a pool gets moved to another Gitaly storage
    shard or is deleted the "source project" relation is not broken.
    However, as of GitLab 12.0 a pool will not fetch from a source
    unless the source is on the same Gitaly shard.

## Consistency between the SQL pool relation and Gitaly

As far as Gitaly is concerned, the SQL pool relations make two types of
claims about the state of affairs on the Gitaly server: pool repository
existence, and the existence of an alternates connection between a
repository and a pool.

### Pool existence

If GitLab thinks a pool repository exists (i.e. it exists according to
SQL), but it does not on the Gitaly server, then it will be created on
the fly by Gitaly.

### Pool relation existence

There are three different things that can go wrong here.

#### 1. SQL says repo A belongs to pool P but Gitaly says A has no alternate objects

In this case, we miss out on disk space savings but all RPC's on A
itself will function fine. The next time garbage collection runs on A,
the alternates connection gets established in Gitaly. This is done by
`Projects::GitDeduplicationService` in gitlab-rails.

#### 2. SQL says repo A belongs to pool P1 but Gitaly says A has alternate objects in pool P2

In this case `Projects::GitDeduplicationService` will throw an exception.

#### 3. SQL says repo A does not belong to any pool but Gitaly says A belongs to P

In this case `Projects::GitDeduplicationService` will try to
"re-duplicate" the repository A using the DisconnectGitAlternates RPC.

## Git object deduplication and GitLab Geo

When a pool repository record is created in SQL on a Geo primary, this
will eventually trigger an event on the Geo secondary. The Geo secondary
will then create the pool repository in Gitaly. This leads to an
"eventually consistent" situation because as each pool participant gets
synchronized, Geo will eventuall trigger garbage collection in Gitaly on
the secondary, at which stage Git objects will get deduplicated.

> TODO How do we handle the edge case where at the time the Geo
> secondary tries to create the pool repository, the source project does
> not exist? <https://gitlab.com/gitlab-org/gitaly/issues/1533>
