#!/bin/zsh
VM_NAME=$1

MULTIPASS_WORKDIR=/Users/hmarino/WORKSPACES/LINUXTIPS/descomplicando-kubernetes/k8s
ANSIBLE_WORKDIR=/Users/hmarino/WORKSPACES/ansible
ANSIBLE_PLAYBOOKS=$ANSIBLE_WORKDIR/playbooks
ANSIBLE_MULTIPASS_INVENTORY=$ANSIBLE_WORKDIR/inventories/multipass_hosts


multipass delete $VM_NAME --purge
multipass launch -n $VM_NAME -c2 -m2g -d5g --cloud-init ./cloud-config.yaml
#multipass shell $VM_NAME
VM_ADDRESS=$(multipass list |awk '{ print $3 }'| awk 'NR!=1 {print}')

if [ ! -f ${ANSIBLE_MULTIPASS_INVENTORY} ]
then
    touch ${ANSIBLE_MULTIPASS_INVENTORY}
    echo "[multipass]" > ${ANSIBLE_MULTIPASS_INVENTORY}  
fi

NEW_LINE="$VM_NAME ansible_host=$VM_ADDRESS ansible_ssh_user=ubuntu"

if [ 'grep $VM_NAME ${ANSIBLE_MULTIPASS_INVENTORY}' ] ; then 
  sed -i 'Ns/.*$VM_NAME.*/$NEW_LINE/' ${ANSIBLE_MULTIPASS_INVENTORY}
else 
  echo $NEW_LINE >> ${ANSIBLE_MULTIPASS_INVENTORY}
fi

ansible-playbook $ANSIBLE_PLAYBOOKS/setup-multipass.yml --limit $VM_ADDRESS
