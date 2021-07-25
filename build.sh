#!/bin/zsh
VM_NAME=$1

multipass delete $VM_NAME --purge
multipass launch -n $VM_NAME -c2 -m2g -d5g --cloud-init ./cloud-config.yaml
multipass shell $VM_NAME
