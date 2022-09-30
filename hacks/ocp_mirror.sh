#!/bin/bash

DEFAULT_VERSION=4.9.12
REGISTRY=git.tigerlab.io:6666
MIRROR=${REGISTRY}/ocp
PULL_SECRET=generated/merged-pull-secret.json
SCRATCH_DIR=scratch

ocp_release_save_to_local() {

OCP_VERSION=${1:-${DEFAULT_VERSION}}
echo "Begining download of OCP version: ${OCP_VERSION}"

oc adm release mirror \
  ${OCP_VERSION} \
  -a ${PULL_SECRET} \
  --to-dir ${SCRATCH_DIR}/release \
  --release-image-signature-to-dir ${SCRATCH_DIR}/sigs
}

ocp_release_push_from_local() {

OCP_VERSION=${1:-${DEFAULT_VERSION}}
echo "Begining push of OCP version: ${OCP_VERSION}"

oc image mirror -a ${PULL_SECRET} \
  --from-dir ${SCRATCH_DIR}/cache \
  "file://openshift/release:${OCP_VERSION}-x86_64*" \
  ${MIRROR}/ocp-release
}

ocp_release_mirror() {

OCP_VERSION=${1:-${DEFAULT_VERSION}}
echo "Begining sync of OCP version: ${OCP_VERSION}"

oc adm release mirror -a ${PULL_SECRET} \
  --from quay.io/openshift-release-dev/ocp-release:${OCP_VERSION}-x86_64 \
  --to ${MIRROR}/ocp-release
}

ocp_catalog_mirror() {

oc adm catalog mirror \
  -a ${PULL_SECRET} \
  registry.redhat.io/redhat/redhat-operator-index:v${OCP_VERSION%.*} \
  ${REGISTRY}/ocp-olm \
  --index-filter-by-os='linux/amd64' \
  --dry-run=false
  #--manifests-only

}
ocp_sync_release_all() {
  # see https://console.redhat.com/openshift/releases

  for ver in 4.7.40; do ocp_sync_mirror $ver; done
  for ver in 4.8.{25,26}; do ocp_sync_mirror $ver; done
  for ver in 4.9.{12,13}; do ocp_sync_mirror $ver; done
}
