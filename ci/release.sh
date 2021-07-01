#! /bin/bash

set -e

PROJECT_ROOT=$(realpath $(dirname "${BASH_SOURCE[0]}")/..)
CHART_ROOT=$(realpath $(dirname "${BASH_SOURCE[0]}")/../chart)

source $PROJECT_ROOT/ci/common.sh

install::helm
install::submodule
helm::fetch_prometheus_operator_chart
helm::fetch_primehub_grafana_dashboard_basic_chart
helm::fetch_nvidia_gpu_exporter
actions::build_release_package
