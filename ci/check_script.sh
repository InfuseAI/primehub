#!/bin/bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SCRIPT_DIR=chart/scripts/controller

function check() {
  local name=$1
  local failed=0

  LOCAL_DIR=$SCRIPT_DIR/$name
  DOWNLOADED_DIR=/tmp/$name

  mkdir -p $DOWNLOADED_DIR
  cd $DOWNLOADED_DIR
  curl -s "https://api.github.com/repos/infuseai/primehub-controller/contents/ee/scripts/$name?ref=master" | jq -r '.[].download_url' | grep -v -e "^null$$" | xargs -I{} curl -s -OL {};
  cd $DIR/..

  for f in `ls $DOWNLOADED_DIR`
  do
    if [[ -f "$LOCAL_DIR/$f" ]]; then
      h1=$(shasum $LOCAL_DIR/$f | cut -d' ' -f1)
      h2=$(shasum $DOWNLOADED_DIR/$f | cut -d' ' -f1)
      if [[ "$h1" != "$h2" ]]; then
        failed=$((failed+1))
      fi
    fi
  done

  echo $failed
}

names=`ls $SCRIPT_DIR`
total_failed=0

for name in $names
do
  failed=$(check $name)

  if [[ $failed != 0 ]]; then
    echo "${name} scripts need to sync"
    total_failed=$((total_failed+failed))
  fi
done

if [[ $total_failed != 0 ]]; then
  exit 1
fi
