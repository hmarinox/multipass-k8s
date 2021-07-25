#!/bin/zsh
VM_NAME=$1

MULTIPASS_WORKDIR=/Users/hmarino/WORKSPACES/LINUXTIPS/descomplicando-kubernetes/k8s
ANSIBLE_WORKDIR=/Users/hmarino/WORKSPACES/ansible
ANSIBLE_PLAYBOOKS=$ANSIBLE_WORKDIR/playbooks
ANSIBLE_MULTIPASS_INVENTORY=$ANSIBLE_WORKDIR/inventories/multipass_hosts

if [ $(multipass list |grep k8smanager01|awk ' { print $1 } ') ]
then
    echo "Removendo $VM_NAME atual..."
    multipass delete $VM_NAME --purge
fi     

echo "Criando novo $VM_NAME..."
multipass launch -n $VM_NAME -c2 -m2g -d5g --cloud-init ./cloud-config.yaml

VM_ADDRESS=$(multipass list |awk '{ print $3 }'| awk 'NR!=1 {print}')

if [ ! -f ${ANSIBLE_MULTIPASS_INVENTORY} ]
then
    echo "Gerando novo inventário"
    touch ${ANSIBLE_MULTIPASS_INVENTORY}
    echo "[multipass]" > ${ANSIBLE_MULTIPASS_INVENTORY}  
fi

NEW_LINE="$VM_NAME ansible_host=$VM_ADDRESS ansible_ssh_user=ubuntu"

if [ $(grep -c $VM_NAME ${ANSIBLE_MULTIPASS_INVENTORY}) -ne 0  ] ; then 
  echo "atualizando inventário..."
  echo "Ns/.*$VM_NAME.*/$NEW_LINE/ ${ANSIBLE_MULTIPASS_INVENTORY}"
  sed -i 'Ns/.*$VM_NAME.*/$NEW_LINE/' ${ANSIBLE_MULTIPASS_INVENTORY}
else 
  echo  "Adicionando $VM_NAME ao inventário..."
  echo $NEW_LINE >> ${ANSIBLE_MULTIPASS_INVENTORY}
fi

echo "Efetuando Setup e Hardening do novo servidor..."
ansible-playbook $ANSIBLE_PLAYBOOKS/setup-multipass.yml --limit $VM_NAME
