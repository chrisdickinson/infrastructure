#!/bin/bash

set -e

eval "$(jq -r '@sh "URL=\(.url) DEPLOY=\(.deploy)"')"
dir=$(mktemp -d)

git clone $URL $dir
mkdir -p $dir/.github/workflows
for i in $DEPLOY/*.yml; do
  cp $i $dir/.github/workflows
done
cd $dir
git add .github/workflows
git commit -m 'update github deploy action'
git push
