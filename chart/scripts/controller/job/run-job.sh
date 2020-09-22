#!/bin/bash
#
# Usage: run-job.sh <command string>
#

# Configurable variable
PHJOB_NAME=${PHJOB_NAME:-job-$(date '+%Y%m%d%H%M%S')}
PHJOB_ARTIFACT_ENABLED=${PHJOB_ARTIFACT_ENABLED:-false}
PHJOB_ARTIFACT_LIMIT_SIZE_MB=${PHJOB_ARTIFACT_LIMIT_SIZE_MB:-100}
PHJOB_ARTIFACT_LIMIT_FILES=${PHJOB_ARTIFACT_LIMIT_FILES:-1000}

COMMAND=$1

# Copy artifiacts
#
# To test artifact copy. We can use
# PHJOB_ARTIFACT_ENABLED=true ARTIFACTS_SRC='/tmp/artifacts/src' ARTIFACTS_DEST="/tmp/artifacts/$(date '+%Y%m%d-%H%M%S')" ./run-job.sh "echo hello"
copy_artifacts() {
  ARTIFACTS_DRYRUN=${ARTIFACTS_DRYRUN:-false}
  ARTIFACTS_SRC=${ARTIFACTS_SRC:-"artifacts"}
  ARTIFACTS_DEST=${ARTIFACTS_DEST:-"/phfs/jobArtifacts/${PHJOB_NAME}"}
  FILE_COUNT_MAX=$PHJOB_ARTIFACT_LIMIT_FILES
  TOTAL_SIZE_MAX=$(($((PHJOB_ARTIFACT_LIMIT_SIZE_MB))*1024*1024))

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
  TOTAL_SIZE=$(du -d 0 "${ARTIFACTS_SRC}" | cut -f 1)
  if (( $TOTAL_SIZE > $TOTAL_SIZE_MAX )); then
    echo "Artifact: Total size exceeds in ${ARTIFACTS_SRC}. ($((TOTAL_SIZE)) > $((TOTAL_SIZE_MAX)))"
    return
  fi

  # Copy the artificats
  if [[ "${ARTIFACTS_DRYRUN}" != true ]]; then
    mkdir -p "${ARTIFACTS_DEST}" || return 1
    cp -R ${ARTIFACTS_SRC}/* ${ARTIFACTS_DEST} || return 1
  else
    echo "Copy artifacts from ${ARTIFACTS_SRC} to ${ARTIFACTS_DEST}"
  fi

  echo "Artifacts: ($((FILE_COUNT)) files / $((TOTAL_SIZE)) bytes) uploaded"
}

# Run Command
bash -c "$COMMAND"
RETCODE=$?

# Copy Artifacts
if [[ "${PHJOB_ARTIFACT_ENABLED}" == "true" ]]; then
  copy_artifacts
fi

# Return result
exit $RETCODE
