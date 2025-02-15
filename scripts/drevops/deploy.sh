#!/usr/bin/env bash
##
# Deploy code to a remote location.
#
# Deployment may include pushing code, pushing created docker image, notifying
# remote hosting service via webhook call etc.
#
# This is a router script to call relevant deployment scripts based on type.
#
# For required variables based on the deployment type,
# see ./scripts/drevops/deployment-[type].sh file.

set -e
[ -n "${DREVOPS_DEBUG}" ] && set -x

# The type of deployment. Can be a combination of comma-separated values (to
# support multiple deployments): code, docker, webhook, lagoon.
DREVOPS_DEPLOY_TYPE="${DREVOPS_DEPLOY_TYPE:-${1}}"

# Deployment action.
# Values can be one of: deploy, deploy_override_db, destroy.
DREVOPS_DEPLOY_ACTION="${DREVOPS_DEPLOY_ACTION:-deploy}"

# Deployment pull request number without "pr-" prefix.
DREVOPS_DEPLOY_BRANCH="${DREVOPS_DEPLOY_BRANCH:-}"

# Deployment pull request number without "pr-" prefix.
DREVOPS_DEPLOY_PR="${DREVOPS_DEPLOY_PR:-}"

# Flag to proceed with deployment. Set to 1 once the deployment configuration
# is configured in CI and is ready.
DREVOPS_DEPLOY_PROCEED="${DREVOPS_DEPLOY_PROCEED:-}"

# Flag to allow skipping of a deployment using additional flags.
# Different to DREVOPS_DEPLOY_PROCEED in a way that DREVOPS_DEPLOY_PROCEED is a failsafe
# to prevent any deployments, while DREVOPS_DEPLOY_SKIP allows to selectively skip
# certain deployments using 'DREVOPS_DEPLOY_SKIP_PR_<NUMBER>' and
# 'DREVOPS_DEPLOY_SKIP_BRANCH_<SAFE_BRANCH>' variables.
DREVOPS_DEPLOY_SKIP="${DREVOPS_DEPLOY_SKIP:-}"

# ------------------------------------------------------------------------------

echo "INFO Started deployment."

[ -z "${DREVOPS_DEPLOY_TYPE}" ] && echo "ERROR Missing required value for DREVOPS_DEPLOY_TYPE. Must be a combination of comma-separated values (to support multiple deployments): code, docker, webhook, lagoon." && exit 1

if [ "${DREVOPS_DEPLOY_PROCEED}" != "1" ]; then
  echo "DREVOPS_DEPLOY_PROCEED is not set to 1." && echo "  OK Skipping deployment ${DREVOPS_DEPLOY_TYPE}." && exit 0
fi

if [ "${DREVOPS_DEPLOY_SKIP}" = "1" ]; then
  echo "     > Found flag to skip a deployment."

  if [ -n "${DREVOPS_DEPLOY_PR}" ]; then
    # Allow skipping deployment by providing 'DREVOPS_DEPLOY_SKIP_PR_<NUMBER>'
    # variable with value set to "1", where <NUMBER> is a PR number name with
    # spaces, hyphens and forward slashes replaced with underscores and then
    # capitalised.
    #
    # Example:
    # For 'pr-123' branch, the variable name is DREVOPS_DEPLOY_SKIP_PR_123
    pr_skip_var="DREVOPS_DEPLOY_SKIP_PR_${DREVOPS_DEPLOY_PR}"
    if [ -n "${!pr_skip_var}" ]; then
      echo "     > Found skip variable ${pr_skip_var} for PR ${DREVOPS_DEPLOY_PR}."
      echo "  OK Skipping deployment ${DREVOPS_DEPLOY_TYPE}." && exit 0
    fi
  fi

  if [ -n "${DREVOPS_DEPLOY_BRANCH}" ]; then
    # Allow skipping deployment by providing 'DREVOPS_DEPLOY_SKIP_BRANCH_<SAFE_BRANCH>'
    # variable with value set to "1", where <SAFE_BRANCH> is a branch name with
    # spaces, hyphens and forward slashes replaced with underscores and then
    # capitalised.
    #
    # Example:
    # For 'main' branch, the variable name is DREVOPS_DEPLOY_SKIP_BRANCH_MAIN
    # For 'feature/my complex feature-123 update' branch, the variable name
    # is DREVOPS_DEPLOY_SKIP_BRANCH_MY_COMPLEX_FEATURE_123_UPDATE
    safe_branch_name="$(echo "${DREVOPS_DEPLOY_BRANCH}" | tr -d '\n' | tr '[:space:]' '_' | tr '-' '_' | tr '/' '_' | tr -cd '[:alnum:]_' | tr '[:lower:]' '[:upper:]')"
    branch_skip_var="DREVOPS_DEPLOY_SKIP_BRANCH_${safe_branch_name}"
    if [ -n "${!branch_skip_var}" ]; then
      echo "     > Found skip variable ${branch_skip_var} for branch ${DREVOPS_DEPLOY_BRANCH}."
      echo "  OK Skipping deployment ${DREVOPS_DEPLOY_TYPE}." && exit 0
    fi
  fi
fi

if [ -z "${DREVOPS_DEPLOY_TYPE##*artifact*}" ]; then
  export DREVOPS_DEPLOY_ARTIFACT_SSH_FINGERPRINT="${DREVOPS_DEPLOY_SSH_FINGERPRINT:-${DREVOPS_DEPLOY_ARTIFACT_SSH_FINGERPRINT}}"
  export DREVOPS_DEPLOY_ARTIFACT_SSH_FILE="${DREVOPS_DEPLOY_SSH_FILE:-${DREVOPS_DEPLOY_ARTIFACT_SSH_FILE}}"
  ./scripts/drevops/deploy-artifact.sh
fi

if [ -z "${DREVOPS_DEPLOY_TYPE##*webhook*}" ]; then
  ./scripts/drevops/deploy-webhook.sh
fi

if [ -z "${DREVOPS_DEPLOY_TYPE##*docker*}" ]; then
  export DREVOPS_DEPLOY_DOCKER_REGISTRY_USERNAME="${DREVOPS_DOCKER_REGISTRY_USERNAME:-${DREVOPS_DEPLOY_DOCKER_REGISTRY_USERNAME}}"
  export DREVOPS_DEPLOY_DOCKER_REGISTRY_TOKEN="${DREVOPS_DOCKER_REGISTRY_TOKEN:-${DREVOPS_DEPLOY_DOCKER_REGISTRY_TOKEN}}"
  export DREVOPS_DEPLOY_DOCKER_REGISTRY="${DREVOPS_DOCKER_REGISTRY:-${DREVOPS_DEPLOY_DOCKER_REGISTRY}}"
  ./scripts/drevops/deploy-docker.sh
fi

if [ -z "${DREVOPS_DEPLOY_TYPE##*lagoon*}" ]; then
  export DREVOPS_DEPLOY_LAGOON_SSH_FINGERPRINT="${DREVOPS_DEPLOY_SSH_FINGERPRINT:-${DREVOPS_DEPLOY_LAGOON_SSH_FINGERPRINT}}"
  export DREVOPS_DEPLOY_LAGOON_SSH_FILE="${DREVOPS_DEPLOY_SSH_FILE:-${DREVOPS_DEPLOY_LAGOON_SSH_FILE}}"
  export DREVOPS_DEPLOY_LAGOON_PROJECT="${LAGOON_PROJECT:-${DREVOPS_DEPLOY_LAGOON_PROJECT}}"
  export DREVOPS_DEPLOY_LAGOON_ACTION="${DREVOPS_DEPLOY_ACTION:-${DREVOPS_DEPLOY_LAGOON_ACTION}}"
  export DREVOPS_DEPLOY_LAGOON_BRANCH="${DREVOPS_DEPLOY_BRANCH:-${DREVOPS_DEPLOY_LAGOON_BRANCH}}"
  export DREVOPS_DEPLOY_LAGOON_PR="${DREVOPS_DEPLOY_PR:-${DREVOPS_DEPLOY_LAGOON_PR}}"
  export DREVOPS_DEPLOY_LAGOON_PR_HEAD="${DREVOPS_DEPLOY_PR_HEAD:-${DREVOPS_DEPLOY_LAGOON_PR_HEAD}}"
  export DREVOPS_DEPLOY_LAGOON_PR_BASE_BRANCH="${DREVOPS_DEPLOY_PR_BASE_BRANCH:-${DREVOPS_DEPLOY_LAGOON_PR_BASE_BRANCH}}"
  ./scripts/drevops/deploy-lagoon.sh
fi

echo "  OK Finished deployment."
