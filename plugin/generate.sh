#!/bin/bash

set -euo pipefail

# the prefix is used to annotate the resources with
# the argocd build environment
: "${ANNOTATION_DOMAIN:=argocd.my-org.io}"

# replace all image refs with exec refs, in Ktptfile pipelines
# this could be more solid, perhaps writing a custom fn to exec ;)
find . -name Kptfile -print0 |
    xargs -0 --no-run-if-empty \
        sed --in-place -E 's|image:.+/(.+):(.+)|exec: \1-\2|'

# render the configuration with the Kptfile pipelines
kpt fn render --allow-exec

# Set annotations from the argocd environment
kpt fn eval --exec set-annotations-v0.1.4 -- \
    "$ANNOTATION_DOMAIN/app=$ARGOCD_APP_NAME" \
    "$ANNOTATION_DOMAIN/rev=$ARGOCD_APP_REVISION" \
    "$ANNOTATION_DOMAIN/repo=$ARGOCD_APP_SOURCE_REPO_URL" \
    "$ANNOTATION_DOMAIN/branch=$ARGOCD_APP_SOURCE_TARGET_REVISION" \
    "$ANNOTATION_DOMAIN/path=$ARGOCD_APP_SOURCE_PATH"

# Lastly, emit the final config by using the remove-local-config-resources
# function which strips all local configs including Kpt files, from the output
kpt fn eval --exec remove-local-config-resources-v0.1.0 --output unwrap
