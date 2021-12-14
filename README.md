# Crystal ManyRepos

Example org to demonstrate creating a monorepo with multiple shards that are synced to dedicated read-only repos using [git subtrees](https://www.atlassian.com/git/tutorials/git-subtree).

## Introduction

Git subtrees allow nesting one or more repositories inside of another within a sub-directory. Changes could then be synced to read-only child repositories in near real-time. This allows development of a Crystal project to reap the benefits of a monorepo, while still adhering to Shard's "1 shard per repo" requirement. This repo represents a mono-repo of a mock project to demonstrate the process/how it looks.

There are some things worth pointing out based on my experiences playing around with this. Definitely open to suggestions/PRs on how to address there, or to add extra info from you experiences:

1. Individual commits from `subtree add` lose association with the prefix.
   1. E.g. https://github.com/crystal-manyrepos/root/commits/master/src/components/one and notice how it does not include the `Add .sum method` commit, only the merge commit when it was added.
2. `git subtree push` needs to traverse _EVERY_ commit, which could lead to performance issues as time goes on.
   1. Are ways that this can be improved, so can worry about it if/when there is a reproducible case of this issue (thousands of commits).

This repo _COULD_ be used as the main shard for the project by defining a `shard.yml` that adds the required components as dependencies, then creating a `src/root.cr` file that requires `"./one"` where that file does `require "one"`. This way both single components can be required as well as all of them.

> **NOTE:** Using this shard results in the source code being duplicated, once from the required child shards, and once from `src/`.  However, since the code from `src/` is never directly required, it won't be included in the binary.

In regards to versioning, one option is to version everything together by syncing tags down to child repos. Another option would be to version each component on its own within the child repos themselves.

## Usage

### Adding a new component

* Subtree in the repo into a related component directory, keeping past history: `git subtree add --squash --prefix src/components/<component-name> git@github.com:crystal-manyrepos/<repo-name>.git <branch>`
  * The `--squash` option can be used to add the child repo's history as one commit, versus essentially duplicating it into the `root` repo. Due to the first gotcha, squashing the history makes the most sense as you would need to use the child repo anyway to look at the full history of files/directories. In this repo `three` was squashed while `one` and `two` were not.
  * **NOTE:** If using a dev branch and creating a PR into `master`, be sure to _NOT_ squash merge the PR, especially when adding more than one child repo, as this will break the special text that goes into the commit message that `git subtree` uses. Create a merge commit or rebase merge to ensure the commits added by `git subtree add` are not altered.
* Update [scripts/sync.sh](scripts/sync.sh) to include handle the new repo
* Add new repo to `shard.dev.yml` as a dependency
* (optional) Add it to `shard.yml` and/or `src/root.cr` as well as making an entry point file within `src/` if this repo is a shard itself

### New development

* Do development in this repo
  * (optional) A  [shard.dev.yml](shard.dev.yml) can be used for testing purposes by installing all child components as symlinks to their [src/components/](src/components/) directory.
    * `SHARDS_OVERRIDE=shard.dev.yml shards update`
* Push up/merge a PR with changes into the `master` branch
  * For example: https://github.com/crystal-manyrepos/root/commit/900cb15f7f43a9962298e97185b324a0151bdc79
* Sync change to remotes
  * `./scripts/sync.sh`
* See commits have been synced:
  * https://github.com/crystal-manyrepos/one/commit/08f64d2e4476da1c1772ba88df00ba9fc190b1c0
  * https://github.com/crystal-manyrepos/two/commit/88ce77827ecd614fcca6e2bbb6983999daab2367

### Automated Sync

The [sync.sh](scripts/sync.sh) script would ideally be invoked as part of a CD flow. I.e. once a PR's checks pass, is approved, and merged into `master`, the sync script would run to push the changes to each child repos in near real time. While there are other options, this can most easily be accomplished via defining a GitHub Action on the `push` event scoped to the `master` branch. An example of how this would look is [.github/workflows/sync.yml](.github/workflows/sync.yml) where `SYNC_TOKEN` is a [Personal Access Token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with the `repo` permissions added as an [Encrypted Secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets).

> **NOTE:** Since a PAT cannot be scoped to certain repos, it is suggested to create a dedicated [Machine User](https://docs.github.com/en/developers/overview/managing-deploy-keys#machine-users) that _only_ has access to the child repos, and no personal repos, to handle the syncing.

An example run using this workflow for the previous `900cb` commit to `root` would look like: https://github.com/crystal-manyrepos/root/runs/4496182825?check_suite_focus=true.
