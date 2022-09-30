#!/bin/bash

SCRATCH_DIR=generated
PATH=${SCRATCH_DIR}/acme.sh:$PATH
ACME_ARGS=$@
EMAIL=${EMAIL:-none@here.net}

clone_acme() {
  if [ ! -e ${SCRATCH_DIR}/acme.sh ]; then
    git clone https://github.com/neilpang/acme.sh ${SCRATCH_DIR}/acme.sh
  fi
}

get_domain() {
  LE_API=$(oc whoami --show-server | cut -f 2 -d ':' | cut -f 3 -d '/' | sed 's/-api././')
  LE_WILDCARD=$(oc get ingresscontroller default -n openshift-ingress-operator -o jsonpath='{.status.domain}')

  echo "LE_API: ${LE_API}"
  echo "LE_WILDCARD: ${LE_WILDCARD}"

}

get_cert() {

  echo "USING: $1"

  acme.sh \
    ${ACME_ARGS} \
    --register-account -m ${EMAIL} \
    --issue \
    -d ${LE_API} \
    -d *.${LE_WILDCARD} \
    --dns $1
}

get_cert_by_svc() {
  
  if [ ! -z $AWS_ACCESS_KEY_ID ]; then
    get_cert dns_aws
  fi

  if [ ! -z $NAMECHEAP_API_KEY ]; then
    echo "NAMECHEAP_SOURCEIP=$(curl -s https://ifconfig.co/ip)"
    get_cert dns_namecheap
  else
    get_cert --yes-I-know-dns-manual-mode-enough-go-ahead-please
  fi

}

copy_cert() {
  
  CERT_DIR=${SCRATCH_DIR}/${LE_API}/certs
  [ ! -e ${CERT_DIR} ] && mkdir -p ${CERT_DIR}
  
  acme.sh --install-cert \
    -d ${LE_API} \
    -d *.${LE_WILDCARD} \
    --cert-file ${CERT_DIR}/cert.pem \
    --key-file ${CERT_DIR}/key.pem \
    --fullchain-file ${CERT_DIR}/fullchain.pem \
    --ca-file ${CERT_DIR}/ca.cer
}

install_ingress() {
  oc delete secret router-certs \
    -n openshift-ingress

  oc create secret tls router-certs \
    -n openshift-ingress \
    --cert=${CERT_DIR}/fullchain.pem \
    --key=${CERT_DIR}/key.pem

  oc patch ingresscontroller default \
    -n openshift-ingress-operator \
    --type=merge \
    --patch='{"spec": { "defaultCertificate": { "name": "router-certs" }}}'
}

install_api() {
  oc delete secret api-certs \
    -n openshift-config

  oc create secret tls api-certs \
    -n openshift-config \
    --cert=${CERT_DIR}/fullchain.pem \
    --key=${CERT_DIR}/key.pem

  oc patch apiserver cluster \
    --type=merge \
    --patch="{\"spec\": {\"servingCerts\": {\"namedCertificates\": [ { \"names\": [  \"$LE_API\"  ], \"servingCertificate\": {\"name\": \"api-certs\" }}]}}}"
}

clone_acme
get_domain
get_cert_by_svc
copy_cert

install_ingress
install_api
