#
# Cookbook:: Kubernetes-Cluster
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
if (node['platform'] == "centos") & (node['platform_version'] >= "7") & (node['kubernetes-cluster']['k8s-version'] == "1.7") & (node['kubernetes-cluster']['agent'] == "master")
  include_recipe 'kubernetes-cluster::kube_master_centos_1.7'
  elsif (node['platform'] == "centos") & (node['platform_version'] >= "7") & (node['kubernetes-cluster']['k8s-version'] == "1.7") & (node['kubernetes-cluster']['agent'] == "minion")
  include_recipe 'kubernetes-cluster::kube_minion_centos_1.7'
  else
  Chef::Log.info('OS Compatibility issue.')
  return
end
