#!/usr/bin/env sh
echo "download model from: $@"
python -u /apps/downloader.py "$@"
echo "done."
exit 0
