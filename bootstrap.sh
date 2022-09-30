#!/bin/bash
set -e
LANG=C

check_oc_login() {
    echo "Validating cluster login..."
    BOOTSTRAP_USER=$(oc whoami || exit 1)
    echo "Current User: $BOOTSTRAP_USER"
}

install_keycloak() {
    NAMESPACE=keycloak
    oc new-project ${NAMESPACE}
    oc process -f https://raw.githubusercontent.com/keycloak/keycloak-quickstarts/latest/openshift-examples/keycloak.yaml \
       -p NAMESPACE=${NAMESPACE} \
    | oc create -f -

    oc set env dc/keycloak PROXY_ADDRESS_FORWARDING=true
    #oc patch svc/keycloak -p $'spec:\n  ports:\n  - port: 8080\n    protocol: TCP\n    targetPort: 8080' -n ${NAMESPACE}
}
