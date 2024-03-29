k8s-haproxy ansible_host=172.16.29.22 ansible_ssh_user=ubuntu
k8smaster01 ansible_host=172.16.29.19 ansible_ssh_user=ubuntu
k8smaster02 ansible_host=172.16.29.20 ansible_ssh_user=ubuntu
k8smaster03 ansible_host=172.16.29.23 ansible_ssh_user=ubuntu
k8sworker01 ansible_host=172.16.29.11 ansible_ssh_user=ubuntu
k8sworker02 ansible_host=172.16.29.12 ansible_ssh_user=ubuntu
k8sworker03 ansible_host=172.16.29.16 ansible_ssh_user=ubuntu


frontend lb-nginx
    mode tcp
    bind 172.16.29.22:32222
    option tcplog
    default_backend lb-nginx-32222


backend k8s-masters
    mode tcp
    balance roundrobin
    option tcp-check
    server k8smaster01 172.16.29.55:32222 check fall 3 rise 2
    server k8smaster02 172.16.29.56:32222 check fall 3 rise 2
    server k8smaster03 172.16.29.57:32222 check fall 3 rise 2


kubeadm init --control-plane-endpoint "k8s-haproxy:6443" --upload-certs




Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join k8s-haproxy:6443 --token audt5f.fza0kcs59aab47qa \
	--discovery-token-ca-cert-hash sha256:18c46dee9befa1701c08df6fd773c85102df6cc9bc7ef540409e0fb15c25f7f3 \
	--control-plane --certificate-key ee2967caae1638035b8b62c5305be5acf65a56010f5fe4a0a1fceda554e8b61a

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join k8s-haproxy:6443 --token audt5f.fza0kcs59aab47qa \
	--discovery-token-ca-cert-hash sha256:18c46dee9befa1701c08df6fd773c85102df6cc9bc7ef540409e0fb15c25f7f3


kubectl label nodes minikube-m02 kubernetes.io/role=worker  
kubectl label nodes minikube-m03 kubernetes.io/role=worker  
