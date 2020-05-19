#!/bin/bash

# this only works for guaranteed pods
echo 500 > /proc/$$/oom_score_adj || true
