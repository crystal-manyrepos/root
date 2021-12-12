# Crystal ManyRepos

Example org to demonstrate creating a monorepo with multiple shards that are synced to dedicated read-only repos using [git subtrees](https://www.atlassian.com/git/tutorials/git-subtree) via [splitsh](https://github.com/splitsh/lite).

## Introduction

Combines the ease of development of a monorepo with the flexability of many repos. This setup can be used to develop a Crystal project, while still adhering to Shard "1 shard per repo" requirement.
This repo represents the "root" shard of a project that requires each of the bundled dependencies within its `shard.yml`.
It sets up some entry point files that will require the default components when the root shard is required. E.g. `require "root"`.
There is also an entry point file for each component to allow only requiring specific sub-components. E.g. `require "root/one"`.
Sub-components that are not required by default can be installed/required manually as needed.

> **NOTE:** Installing the root shard also copies the `src/` directory which essentially duplicates the code. That code is never required directly, so will be excluded from the binary.

All development for the project can take place in this one repo, and changes could be synced to a read-only repo for each sub-component.

## Usage

* Do development in this repo
  * A [shard.dev.yml](shard.dev.yml) file can be used to install all child shards as symlinks to their [src/components/](src/components/) directory. The entire project could then be required via `require "./src/root"` via a `./test.cr` file for example.
    * `$ SHARDS_OVERRIDE=shard.dev.yml shards update`
* Make a PR with changes into main root
  * For example: https://github.com/crystal-manyrepos/root/pull/3
* Merge PR
* Sync change to remotes
  * `$ ./scripts/sync.sh`
* See commits have been synced:
  * https://github.com/crystal-manyrepos/one/commit/e981d57d0af55211e2f4c5523ea6604107e8ae75
  * https://github.com/crystal-manyrepos/two/commit/b4c9c2653c8705890e19bb7c6f5ef7d7676900d2

### Adding a new component

* Subtree in the repo into a related component directory, keeping past history:
  * $ `git subtree add --prefix src/components/<component-name> git@github.com:crystal-manyrepos/<repo-name>.git <branch>`
    * The `--squash` option may be used if you'd rather squash past history into one commit + merge commit.
* Update [scripts/sync.sh](scripts/sync.sh) to include handle the new repo
* (Optional) Add new repo to `shard.yml` as a dependency if it should be included by default
  * Also add a new entry point file within `src/` and add it to [src/root.cr](src/root.cr).

### Automated Sync

The [sync.sh](scripts/sync.sh) script would ideally be invoked as part of a CD flow. I.e. once a PR's checks pass, is approved, and merged into master, the sync script would run to push the changes to each child repos in near real time. While there are other options, this can most easily be accomplished via defining a GitHub Action on the `push` event scoped to the `master` branch. An example of how this would look is [.github/workflows/sync.yml](.github/workflows/sync.yml) where `SYNC_TOKEN` is a [Personal Access Token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with the `repo` permissions added as an [Encrypted Secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets).

> **NOTE:** Since a PAT cannot be scoped to certain repos, it is suggested to create a dedicated [Machine User](https://docs.github.com/en/developers/overview/managing-deploy-keys#machine-users) that _only_ has access to the child repos, and no personal repos, to handle the syncing.

An example run using this workflow would look like [this](https://github.com/crystal-manyrepos/root/runs/4479189998?check_suite_focus=true); where it syncs https://github.com/crystal-manyrepos/root/commit/1d2e9265609fa5ad945a5e8138f54409fe36585b to https://github.com/crystal-manyrepos/one/commit/a7a63d3192a51e9876e1b18c97ee461323a41fac.
