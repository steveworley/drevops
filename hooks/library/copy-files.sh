#!/usr/bin/env bash
##
# Acquia Cloud hook: Copy files between environments.
#
# Environment variables must be set in Acquia UI globally or for each environment.

set -e
[ -n "${DREVOPS_DEBUG}" ] && set -x

site="${1}"
target_env="${2}"

[ "${DREVOPS_TASK_COPY_FILES_ACQUIA_SKIP}" = "1" ] && echo "Skipping copying of files between Acquia environments." && exit 0

export DREVOPS_TASK_COPY_FILES_ACQUIA_KEY="${DREVOPS_TASK_COPY_FILES_ACQUIA_KEY?not set}"
export DREVOPS_TASK_COPY_FILES_ACQUIA_SECRET="${DREVOPS_TASK_COPY_FILES_ACQUIA_SECRET?not set}"
export DREVOPS_TASK_COPY_FILES_ACQUIA_APP_NAME="${DREVOPS_ACQUIA_APP_NAME:-${site}}"
export DREVOPS_TASK_COPY_FILES_ACQUIA_SRC="${DREVOPS_TASK_COPY_FILES_ACQUIA_SRC:-prod}"
export DREVOPS_TASK_COPY_FILES_ACQUIA_DST="${DREVOPS_TASK_COPY_FILES_ACQUIA_DST:-${target_env}}"

"/var/www/html/${site}.${target_env}/scripts/drevops/task-copy-files-acquia.sh"
