#!/bin/zsh
# Author: hmarinox
# Script to provisioning a new multipass VM
# Usage: build.sh [ VM Name ]

MULTIPASS_WORKDIR=/Users/hmarino/WORKSPACES/LINUXTIPS/descomplicando-kubernetes/k8s
ANSIBLE_WORKDIR=/Users/hmarino/WORKSPACES/ansible
ANSIBLE_PLAYBOOKS=$ANSIBLE_WORKDIR/playbooks
ANSIBLE_MULTIPASS_INVENTORY=$ANSIBLE_WORKDIR/inventories/multipass_hosts

red=`tput setaf 1`
green=`tput setaf 2`
mag=`tput setaf 5`
reset=`tput sgr0`


if [ $(multipass list |grep k8s-master-01|awk ' { print $1 } ') ]
then
    echo "🗑️ ${mag} Removendo k8s-master-01 antigo... ${reset}"
    multipass delete k8s-master-01 --purge
fi
echo "☸️  ${mag} Criando Control Plane ${reset}"
multipass launch -n k8s-master-01 -c2 -m2g -d15g --cloud-init ./cloud-config.yaml

if [ $(multipass list |grep k8s-worker-01|awk ' { print $1 } ') ]
then
    echo "🗑️ ${mag} Removendo k8s-worker-01 antigo... ${reset}"
    multipass delete k8s-worker-01 --purge
fi
echo "🖥️  ${mag} Criando worker node 1 ${reset}"
multipass launch -n k8s-worker-01 -c2 -m2g -d15g --cloud-init ./cloud-config.yaml

if [ $(multipass list |grep k8s-worker-02|awk ' { print $1 } ') ]
then
    echo "🗑️ ${mag} Removendo k8s-worker-02 antigo... ${reset}"
    multipass delete k8s-worker-02 --purge
fi
echo "🖥️  ${mag} Criando worker node 2 ${reset}"
multipass launch -n k8s-worker-02 -c2 -m2g -d15g --cloud-init ./cloud-config.yaml

echo "💾  ${mag} Gerando Inventário... ${reset}"

echo "[k8smaster]" > ${ANSIBLE_MULTIPASS_INVENTORY}
while IFS= read -r line
do
    echo "$line" >> ${ANSIBLE_MULTIPASS_INVENTORY}
done <<< $(multipass list|grep master|awk '{ print $1 " ansible_host="$3 " ansible_ssh_user=ubuntu kubernetes_role=master"}')

echo "[k8snode]" >> ${ANSIBLE_MULTIPASS_INVENTORY}
while IFS= read -r line
do
    echo "$line" >> ${ANSIBLE_MULTIPASS_INVENTORY}
done <<< $(multipass list|grep worker|awk '{ print $1 " ansible_host="$3 " ansible_ssh_user=ubuntu kubernetes_role=node"}')

echo "[multipass:children]" >> ${ANSIBLE_MULTIPASS_INVENTORY}
echo "k8smaster" >> ${ANSIBLE_MULTIPASS_INVENTORY}
echo "k8snode" >> ${ANSIBLE_MULTIPASS_INVENTORY}

echo "🛡️  ${mag} Efetuando Setup e Hardening... ${reset}"
ansible-playbook $ANSIBLE_PLAYBOOKS/playbook-hardening.yml

echo "🐳  ${mag} Efetuando Setup do Docker CE... ${reset}"
ansible-playbook $ANSIBLE_PLAYBOOKS/playbook-docker.yml

echo "🔱  ${mag} Efetuando Setup do Cluster Kubernetes... ${reset}"
ansible-playbook $ANSIBLE_PLAYBOOKS/playbook-k8s.yml

echo "💻  ${meg} Conectando na nova VM ${reset}"
multipass shell k8s-master-01
