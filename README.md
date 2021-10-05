Multipass vm builder with k8s


To use, clone main branch, adjusts variables and execute build.sh.

Dependencies:

  Multipass + ansible + docker.

  Tested only on MacOS.

---------

Modules:
/etc/modules-load.d/k8s.conf

br_netfilter
ip_vs
ip_vs_rr
ip_vs_sh
ip_vs_wrr
nf_conntrack_ipv4
