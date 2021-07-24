#!/bin/sh

multipass delete --all --purge
multipass launch -n k8sn1 -c1 -m1g -d5g --cloud-init=./cloud-init.yaml
multipass shell k8sn1
