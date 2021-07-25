#!/bin/zsh

red=`tput setaf 1`
green=`tput setaf 2`
mag=`tput setaf 5`
reset=`tput sgr0`

VM_NAME=$1
MULTIPASS_WORKDIR=/Users/hmarino/WORKSPACES/LINUXTIPS/descomplicando-kubernetes/k8s
ANSIBLE_WORKDIR=/Users/hmarino/WORKSPACES/ansible
ANSIBLE_PLAYBOOKS=$ANSIBLE_WORKDIR/playbooks
ANSIBLE_MULTIPASS_INVENTORY=$ANSIBLE_WORKDIR/inventories/multipass_hosts

if [ $(multipass list |grep $VM_NAME|awk ' { print $1 } ') ]
then
    echo "🪓  ${mag}Removendo $VM_NAME atual...${reset}"
    multipass delete $VM_NAME --purge
fi     

echo "🔨  ${mag}Criando novo $VM_NAME...${reset}"
multipass launch -n $VM_NAME -c2 -m2g -d5g --cloud-init ./cloud-config.yaml

echo "💾  ${mag}Gerando Inventário...${reset}"
echo "[multipass]" > ${ANSIBLE_MULTIPASS_INVENTORY}  
while IFS= read -r line
do
    echo "$line" >> ${ANSIBLE_MULTIPASS_INVENTORY}
done <<< $(multipass list|awk '{ print $1 " ansible_host="$3 " ansible_ssh_user=ubuntu"}' |awk 'NR!=1 {print}')

echo "🛠  ${mag}Efetuando Setup e Hardening do novo servidor...${reset}"
ansible-playbook $ANSIBLE_PLAYBOOKS/setup-multipass.yml --limit $VM_NAME