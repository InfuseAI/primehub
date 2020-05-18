#!/bin/sh

git config --global core.packedGitLimit "512m"
git config --global core.packedGitWindowSize "32m"
git config --global core.bigFileThreshold "32m"
git config --global pack.deltaCacheSize "64m"
git config --global pack.windowMemory "128m"
