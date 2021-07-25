#!/bin/zsh
VM_NAME=$1

MULTIPASS_WORKDIR=/Users/hmarino/WORKSPACES/LINUXTIPS/descomplicando-kubernetes/k8s
ANSIBLE_WORKDIR=/Users/hmarino/WORKSPACES/ansible
ANSIBLE_PLAYBOOKS=$ANSIBLE_WORKDIR/playbooks


multipass delete $VM_NAME --purge
multipass launch -n $VM_NAME -c2 -m2g -d5g --cloud-init ./cloud-config.yaml
#multipass shell $VM_NAME
VM_ADDRESS=$(multipass list |awk '{ print $3 }'| awk 'NR!=1 {print}')
ansible-playbook $ANSIBLE_PLAYBOOKS/setup-multipass.yml --limit $VM_ADDRESS
