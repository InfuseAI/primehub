#!/bin/bash

set -e

CHART_NAME=primehub
CHART_ROOT=$(dirname "${BASH_SOURCE[0]}")/../$CHART_NAME
PROJECT_ROOT=$(dirname "${BASH_SOURCE[0]}")/..

source $PROJECT_ROOT/ci/common.sh

helm::workaround_rename
helm::update_dependency
helm::package
