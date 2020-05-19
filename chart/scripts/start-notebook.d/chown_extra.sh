#!/bin/bash

if [ ! -z "$CHOWN_EXTRA" ]; then
    for extra_dir in $(echo $CHOWN_EXTRA | tr ',' ' '); do
        chown $CHOWN_EXTRA_OPTS $NB_UID:$NB_GID $extra_dir || true
    done
fi
