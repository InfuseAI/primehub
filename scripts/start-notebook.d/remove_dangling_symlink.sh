#!/bin/bash

find /home/jovyan -maxdepth 1 -type l -exec test ! -e {} \; -print -delete
