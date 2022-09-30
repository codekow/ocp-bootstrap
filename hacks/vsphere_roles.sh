#!/bin/bash

VSPHERE_ROLES='
  openshift-vcenter-level
  openshift-cluster-level
  openshift-datastore-level
  openshift-portgroup-level
  openshift-folder-level
  openshift-datacenter-level
  vbmc4vsphere
'

mkdir -p generated

check_govc() {
which govc || exit 1
}

print_usage() {
echo "Usage: source hacks/vsphere_roles.sh"
echo "
  Run: vsphere_{dump_roles,create_roles,remove_roles,diff_roles}
"

}

read_login() {
  
if [ ! "${GOVC_URL}x" == "x" ]; then
  echo \$GOVC_URL already set
  print_usage
else
  GOVC_URL=10.1.2.3
  GOVC_USERNAME=Administrator
  read -p "vSphere Host/IP [${GOVC_URL}]: " GOVC_URL
  read -p "vSphere User [${GOVC_USERNAME}]: " GOVC_USERNAME
  read -p "vSphere Password: " -s GOVC_PASSWORD
  echo
  
  GOVC_URL=${GOVC_URL:-10.1.2.3}
  GOVC_USERNAME=${GOVC_USERNAME:-Administrator}
  GOVC_INSECURE=${GOVC_INSECURE:-true}
  
  export GOVC_URL="${GOVC_USERNAME}:${GOVC_PASSWORD}@${GOVC_URL}"
  
  echo "GOVC_INSECURE: ${GOVC_INSECURE}"
  print_usage

fi
}

vsphere_dump_roles() {

for ROLE in ${VSPHERE_ROLES}
do
  echo "ROLE: ${ROLE}"
  govc role.ls "${ROLE}" | tee generated/role.${ROLE}
  echo
done
}

vsphere_create_roles() {

for ROLE in ${VSPHERE_ROLES}
do
  govc role.create ${ROLE}
  govc role.update ${ROLE} $(cat conf/vsphere/role.${ROLE})
done
}

vsphere_remove_roles() {

for ROLE in ${VSPHERE_ROLES}
do
  echo govc role.remove ${ROLE}
done
}

vsphere_diff_roles() {

vsphere_dump_roles

for ROLE in ${VSPHERE_ROLES}
do
  diff -u conf/vsphere/role.${ROLE} generated/role.${ROLE}
done
}

check_govc
read_login
