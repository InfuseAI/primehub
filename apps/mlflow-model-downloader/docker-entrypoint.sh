#!/usr/bin/env sh
echo "download model from: $@"
python /apps/downloader.py "$@"
echo "done."
exit 0
