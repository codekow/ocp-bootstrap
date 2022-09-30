# OCP Bootstrap

## Quickstart

Use the file `vars_[ platform ].yml` as a template to create `my_vars.yml`

```
# install python
sudo yum -y install python3 python3-pip

# setup python virtual env
python3 -m venv venv
. venv/bin/activate
pip install -U pip

# setup ansible
pip install -r requirements.txt

# ocp install
ansible-playbook playbooks/main.yml -e @my_vars.yml -e run_local=true

```

## Cleanup
```
# destroy openshift cluster
ansible-playbook playbooks/destroy.yml -e @my_vars.yml

# destory venv / scratch files
deactivate
rm -rf venv generated
```

## VMware

```
# init / setup password
. hacks/vsphere_roles.sh

# confirm roles
vsphere_dump_roles

# check config drift in vcenter
vsphere_diff_roles

# create / update roles in vcenter
vsphere_create_roles

```

## Lets Encrypt

```
# init functions
. hacks/lets_encrypt.sh

#TBD
```

# Potential Bugs

- See https://github.com/openshift/installer/pull/5173

# TODO:
- Setup DNS for AWS
- Setup DNS for Tiger Lab
- Automate LetsEncrypt


## Links

Installing OCP
- https://docs.openshift.com/container-platform/4.8/installing/install_config/installing-customizing.html#installation-special-config-storage_installing-customizing

LetsEncrypt
- https://github.com/redhat-cop/gitops-catalog/blob/main/letsencrypt-certs/base/job.yaml
- https://cloud.redhat.com/blog/requesting-and-installing-lets-encrypt-certificates-for-openshift-4
- https://github.com/acmesh-official/acme.sh/wiki/dnsapi
- https://docs.openshift.com/container-platform/4.1/networking/routes/route-configuration.html#nw-enabling-hsts_route-configuration

Misc
- https://github.com/redhat-canada-gitops/argocd
- https://github.com/redhat-cop/gitops-catalog
- https://github.com/christianh814/openshift-cluster-config
- https://github.com/mali-chainzee/OpenShift-Provisioner
- https://github.com/codekow/openshift-aio/blob/main/playbooks/main.yml
- https://gitlab.consulting.redhat.com/vsira/ocp4-automation-swift/-/tree/master/tasks
- https://github.com/strangiato/catalog/tree/kustomize-build-test
- https://gitlab.consulting.redhat.com/intelligent-application-practice/xray/cluster-bootstrap/-/blob/main/bootstrap.sh
- https://github.com/RedHatWorkshops/openshift-cicd-demo
- https://github.com/christianh814/openshift-cluster-config

Ansible
- https://serverfault.com/questions/768470/how-to-enumerate-network-interfaces-in-ansible
- https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debug_module.html

VSphere
- https://docs.openshift.com/container-platform/4.8/post_installation_configuration/cluster-tasks.html#available_cluster_customizations
- https://docs.openshift.com/container-platform/4.8/installing/installing_vsphere/installing-vsphere-installer-provisioned-customizations.html#installing-vsphere-installer-provisioned-customizations
- https://kb.vmware.com/s/article/2105932
- https://github.com/openshift/installer/blob/master/docs/user/vsphere/privileges.md
- https://access.redhat.com/solutions/5186701
