#!/bin/bash

if [ -d "$HOME/$GROUP_NAME" ]; then
  # group volume mounted
  export PRIMEHUB_GROUP_VOLUME_PATH="$HOME/$GROUP_NAME"
  export PRIMEHUB_PHFS_PATH="$HOME/phfs"
  export PRIMEHUB_USER=$NB_USER
  export PRIMEHUB_GROUP=$GROUP_NAME
fi

# if we're in safe mode, skip everything
if [ ! -d "$HOME/user" ]; then
  if [ -d "$HOME/$GROUP_NAME" ]; then
    # source group profile
    if [ -f "$PRIMEHUB_GROUP_VOLUME_PATH/.primehub/profile" ]; then
      echo "sourcing group profile"
      source "$PRIMEHUB_GROUP_VOLUME_PATH/.primehub/profile"
    else
      echo "group profile not found"
    fi

    # source user profile
    echo "user = $NB_USER"

    if [ -f "$PRIMEHUB_GROUP_VOLUME_PATH/.primehub/$NB_USER.profile" ]; then
      echo "sourcing user profile"
      source "$PRIMEHUB_GROUP_VOLUME_PATH/.primehub/$NB_USER.profile"
    else
      echo "user profile not found"
    fi
  fi
else
  echo "skip loading profile when in safe mode"
fi

