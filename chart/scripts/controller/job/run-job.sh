#!/bin/bash
#
# Usage: run-job.sh <command string>
#

# Configurable variable
PHJOB_NAME=${PHJOB_NAME:-job-$(date '+%Y%m%d%H%M%S')}
PHJOB_ARTIFACT_ENABLED=${PHJOB_ARTIFACT_ENABLED:-false}
PHJOB_ARTIFACT_LIMIT_SIZE_MB=${PHJOB_ARTIFACT_LIMIT_SIZE_MB:-100}
PHJOB_ARTIFACT_LIMIT_FILES=${PHJOB_ARTIFACT_LIMIT_FILES:-1000}
GRANT_SUDO=${GRANT_SUDO:-true}
PHJOB_ARTIFACT_RETENTION_SECONDS=${PHJOB_ARTIFACT_RETENTION_SECONDS:-604800}
ARTIFACTS_DEST=${ARTIFACTS_DEST:-"/phfs/jobArtifacts/${PHJOB_NAME}"}

COMMAND=$1

# Copy artifiacts
#
# To test artifact copy. We can use
# PHJOB_ARTIFACT_ENABLED=true ARTIFACTS_SRC='/tmp/artifacts/src' ARTIFACTS_DEST="/tmp/artifacts/$(date '+%Y%m%d-%H%M%S')" ./run-job.sh "echo hello"
copy_artifacts() {
  local ARTIFACTS_DRYRUN=${ARTIFACTS_DRYRUN:-false}
  local ARTIFACTS_SRC=${ARTIFACTS_SRC:-"artifacts"}
  local ARTIFACTS_DEST=${ARTIFACTS_DEST:-"/phfs/jobArtifacts/${PHJOB_NAME}"}
  local FILE_COUNT_MAX=$PHJOB_ARTIFACT_LIMIT_FILES
  local TOTAL_SIZE_MAX=$PHJOB_ARTIFACT_LIMIT_SIZE_MB
  local RETENTION=$PHJOB_ARTIFACT_RETENTION_SECONDS

  if [[ ! -e ${ARTIFACTS_SRC} ]]; then
    echo "Artifacts: no artifact found"
    return
  fi

  if [[ -L ${ARTIFACTS_SRC} ]]; then
    ARTIFACTS_SRC=$(readlink -f ${ARTIFACTS_SRC})
  fi

  if [[ -f ${ARTIFACTS_SRC} ]]; then
    echo "Artifacts: ${ARTIFACTS_SRC} is not a directory"
    return
  fi

  if [[ ! -d ${ARTIFACTS_SRC} ]]; then
    echo "Artifact: ${ARTIFACTS_SRC} is not a directory"
    return
  fi

  # Check file count
  FILE_COUNT=$(find "${ARTIFACTS_SRC}" -type f | wc -l)
  if (( $FILE_COUNT > $FILE_COUNT_MAX )); then
    echo "Artifact: Too many file in ${ARTIFACTS_SRC}. ($((FILE_COUNT)) > $((FILE_COUNT_MAX)))"
    return
  elif (( $FILE_COUNT == 0 )); then
    echo "Artifacts: no artifact found"
    return
  fi

  # Check file size
  TOTAL_SIZE=$(du -m -d 0 "${ARTIFACTS_SRC}" | cut -f 1)
  if (( $TOTAL_SIZE > $TOTAL_SIZE_MAX )); then
    echo "Artifact: Total size exceeds in ${ARTIFACTS_SRC}. ($((TOTAL_SIZE))M > $((TOTAL_SIZE_MAX))M)"
    return
  fi

  # Copy the artificats
  if [[ "${ARTIFACTS_DRYRUN}" != true ]]; then
    mkdir -p "${ARTIFACTS_DEST}" || return 1
    cp -R ${ARTIFACTS_SRC}/* ${ARTIFACTS_DEST} || return 1
  else
    echo "Copy artifacts from ${ARTIFACTS_SRC} to ${ARTIFACTS_DEST}"
  fi

  # Metadata
  mkdir -p "${ARTIFACTS_DEST}/.metadata"
  if (( $RETENTION > 0 )); then
    echo "$(($(date +%s) + $RETENTION))" >> "${ARTIFACTS_DEST}/.metadata/expiredAt"
  fi

  # Prompt information
  echo "Artifacts: ($((FILE_COUNT)) files / $((TOTAL_SIZE)) MB) uploaded"
}

monitoring_start() {
  # Launch Monitoring Agent when PHJOB_ARTIFACT_ENABLED
  if [[ "${PHJOB_ARTIFACT_ENABLED}" == "true" ]]; then
    if [[ -x /monitoring-utils/primehub-monitoring-agent ]]; then
      mkdir -p "${ARTIFACTS_DEST}/.metadata" || true
      /monitoring-utils/primehub-monitoring-agent
    fi
  fi
}

monitoring_stop() {
  if [[ -f .monitoring-agent.pid ]]; then
    # flush buffer to file
    kill -1 $(cat .monitoring-agent.pid)
    # stop the agent
    kill -9 $(cat .monitoring-agent.pid)
  fi
}

# Grant sudo
if [[ "${GRANT_SUDO}" == "true" ]]; then
  if [[ -n $NB_USER ]]; then
    USER=$NB_USER
  fi
  if [[ -n $USER ]] && [[ -d /etc/sudoers.d ]]; then
    echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/job
  fi
fi

# Refresh ldconfig cache
ldconfig

monitoring_start

# Run Command
if command -v sudo > /dev/null && [[ "$GRANT_SUDO" == "true" ]] && [[ -n $USER ]]; then
  sudo -E -H -u $USER PATH=$PATH bash -c "$COMMAND"
else
  bash -c "$COMMAND"
fi
RETCODE=$?

# Copy Artifacts
if [[ "${PHJOB_ARTIFACT_ENABLED}" == "true" ]]; then
  copy_artifacts
  monitoring_stop
fi

# Return result
exit $RETCODE
