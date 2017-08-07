#
# Cookbook:: Kubernetes-Cluster
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Cluster empty role name
default['kubernetes-cluster']['localhost'] = '127.0.0.1'
default['kubernetes-cluster']['hostname'] = 'kubemaster'
default['kubernetes-cluster']['ipaddress'] = '10.0.11.176'
# Port List for Follwing Services -
default['kubernetes-cluster']['kubelet'] = '10255'
default['kubernetes-cluster']['kube-scheduler'] = '10251'
default['kubernetes-cluster']['kube-controlle'] = '10252'
default['kubernetes-cluster']['kube-proxy'] = '10256'
default['kubernetes-cluster']['kube-apiserver'] = '6443'
default['kubernetes-cluster']['etcd'] = '2380'
default['kubernetes-cluster']['weave-npc'] = '6781'
default['kubernetes-cluster']['weaver'] = '6782'
default['kubernetes-cluster']['k8s-version'] = '1.7'
default['kubernetes-cluster']['token'] = '7de59e.b859a71e082d41a5'
default['kubernetes-cluster']['agent'] = 'master'
