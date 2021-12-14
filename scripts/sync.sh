#!/usr/bin/env bash
## Based on https://github.com/laravel/framework/blob/d1ef8e588cc7efc3b3cf925b42f134aa54a4f9c7/bin/split.sh

set -e
set -x

CURRENT_BRANCH="master"

function remote()
{
    git remote add $1 $2 || true
    git fetch $1
}

function split()
{
    git subtree push --prefix="$1" $2 $CURRENT_BRANCH
}

git pull origin $CURRENT_BRANCH

remote one https://github.com/crystal-manyrepos/one.git
remote two https://github.com/crystal-manyrepos/two.git
remote three https://github.com/crystal-manyrepos/three.git

split 'src/components/one' one
split 'src/components/two' two
split 'src/components/three' three
