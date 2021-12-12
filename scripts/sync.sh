#!/usr/bin/env bash
## Based on https://github.com/laravel/framework/blob/d1ef8e588cc7efc3b3cf925b42f134aa54a4f9c7/bin/split.sh

set -e
set -x

CURRENT_BRANCH="master"

function sync()
{
    git subtree push --prefix="src/components/$1" "https://github.com/crystal-manyrepos/$1.git" $CURRENT_BRANCH
}

git pull origin $CURRENT_BRANCH

# sync one
