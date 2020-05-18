#!/bin/sh

# sleep random
if [ "${GIT_SYNC_DELAY_INIT:-FALSE}" == "TRUE" ]; then
  sleep $(( ( RANDOM % 1800 )  + 1 ))
fi

# cleanup folder if existing repo url isn't the same as new one
if [ -f "$GIT_SYNC_ROOT/.git/config" ]; then
  repo_url=$(cat "$GIT_SYNC_ROOT/.git/config" | grep 'url = ' | cut -d'=' -f2 | xargs )
  if [ "$repo_url" != "$GIT_SYNC_REPO" ]; then
    rm -rf $GIT_SYNC_ROOT/.git
    rm -rf $GIT_SYNC_ROOT/$GIT_SYNC_DEST
    rm -rf $GIT_SYNC_ROOT/rev*
  fi
fi
