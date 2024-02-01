#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if [ -z "${BUILDKITE_BRANCH-}" ]; then
    BRANCH="$(git rev-parse --abbrev-ref HEAD)"
else
    BRANCH="${BUILDKITE_BRANCH}"
fi

if [ -z "${BUILDKITE_BUILD_NUMBER-}" ]; then
    BUILD_NUMBER=0
else
    BUILD_NUMBER="${BUILDKITE_BUILD_NUMBER}"
fi

if [ -z "${BUILDKITE_COMMIT-}" ]; then
    COMMIT="$(git rev-parse HEAD)"
else
    COMMIT="${BUILDKITE_COMMIT}"
fi

BRANCH="${BRANCH//\//_}"
BRANCH="${BRANCH//#/_}"
BRANCH="$(echo "${BRANCH}" | tr '[:upper:]' '[:lower:]')"

# tag format:
#   some_branch-YY_MM_DD-42_abcedf
IMAGE_TAG="${BRANCH}-$(date '+%Y_%m_%d')-${BUILD_NUMBER}-${COMMIT:0:7}"

echo $IMAGE_TAG