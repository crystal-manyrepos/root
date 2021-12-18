#!/usr/bin/env bash
## Based on https://github.com/laravel/framework/blob/d1ef8e588cc7efc3b3cf925b42f134aa54a4f9c7/bin/split.sh

set -e

CURRENT_BRANCH="master"

# Syncs the provided component if changes were made within the provided sub directory
#
# $1 - Sub directory path
# $2 - Component name
# $3 - Git URL
function maybeSync()
{
  if ! $(git diff --quiet --exit-code $BEFORE_SHA $AFTER_SHA -- $1); then
    echo "::group::Syncing $1"
    git remote add $2 $3 || true
    git fetch $2
    git subtree push --prefix="$1" $2 $CURRENT_BRANCH
    echo "::endgroup::"
  fi
}

maybeSync 'src/components/one' one https://github.com/crystal-manyrepos/one.git
maybeSync 'src/components/two' two https://github.com/crystal-manyrepos/two.git
maybeSync 'src/components/three' three https://github.com/crystal-manyrepos/three.git
