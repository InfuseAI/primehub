#!/bin/bash
ulimit -n 65535 || true # Maximum number of open file descriptors
ulimit -u 65535 || true # Maximum number of processes available to a single user
