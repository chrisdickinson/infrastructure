#!/bin/bash

set -e
exec 6>&1
exec > /dev/null
exec 2>&1
eval "$(jq -r '@sh "URL=\(.url) DEPLOY=\(.deploy)"')"
dir=$(mktemp -d)

git clone $URL $dir
mkdir -p $dir/.github/workflows
for i in $DEPLOY/*.yml; do
  cp $i $dir/.github/workflows
done
cd $dir
result=0
git add .github/workflows || result=$?
git commit -m 'update github deploy action' || result=$?
if [ $result -ne 0 ]; then
  exec 1>&6 6>&-
  echo '{"result": "no updates for '$URL'"}'
else
  git push
  exec 1>&6 6>&-
  echo '{"result": "updated '$URL'"}'
fi
rm -rf $dir
