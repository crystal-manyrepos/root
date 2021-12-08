# Crystal ManyRepos

Example org to demonstrate creating a monorepo with multiple shards that are synced to dedicated read-only repos via [git subtrees](https://www.atlassian.com/git/tutorials/git-subtree).

## Usage

This process allows using a monorepo for development of a Crystal project, while still adhering to Shard "1 shard per repo" requirement.
This repo represents the "root" shard of a project/framework that requires each of the dependencies within its `shard.yml`.
It sets up some entry point files that will require all/default components when the root is required. E.g. `require "root"`.
There is also an entry point file for each component to allow only requiring specific sub-components. E.g. `require "root/one"`.

> **NOTE:** Installing the root shard also copies the `src/` directory which essentially duplicates the code. That code is never required directly, so it should be excluded from the binary.

All development for the project can take place in this one repo, and changes could be synced to a read-only repo for each sub-component.

TODO: Add `Makefile`?

### Adding a new component

1. Add new repo as a remote:
  * `git remote add -f <repo-name> git@github.com:crystal-manyrepos/<repo-name>.git`
1. Subtree in the repo into a related component directory:
  * `git subtree add --prefix src/components/<component-name> <repo-name> <branch> --squash`
  * TODO: How to handle migrating an existing project? Merge, squash merge, or just copy the code in directly and start fresh?

### Sync changes to remote

1. Do development in this repo
  * TODO: How to best handle dependency management during dev
    * I.e. how could you just `require "src/root"` and use everything without installing the shard deps directly or needing relative requires
      * Maybe a dev `shard.yml` using `path` requires?
1. Make a PR with changes into main root
  * For example: https://github.com/crystal-manyrepos/root/pull/2
1. Merge PR
1. Sync change to remotes
  * `git subtree push --prefix=src/components/<repo-name>/ <repo-name> <branch>`
    * Calling it again noops given there are no changes
  * TODO: Probably is some automation that could do this. E.g. GHA or something.
