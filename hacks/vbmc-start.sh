#!/bin/bash

IPMI_USER=admin
IPMI_PASS=password
IPMI_HOST=10.1.20.119
IPMI_ARGS="power status"

vbmc_cmd(){

ARGS=${@:-${IPMI_ARGS}}
echo "EXAMPLE:
  vbmc_cmd chassis bootdev pxe"

echo "IPMITOOL:
  ipmitool -I lanplus -U [IPMI_USER] -P [IPMI_PASS] -H [IPMI_HOST] -p [PORT] [ARGS]"

echo ARGS: ${ARGS}

for i in {0..6}
do
  ipmitool \
    -I lanplus \
    -U ${IPMI_USER} \
    -P ${IPMI_PASS} \
    -H ${IPMI_HOST} \
    -p 624${i} \
    ${ARGS}
done
}

