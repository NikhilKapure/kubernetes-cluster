#
# Cookbook Name:: kubernetes-cluster
# Recipe:: default
#
# Copyright 2017, REAN Cloud
#
# All rights reserved - Do Not Redistribute
#=======================================================================================================================
# _____________________________________________________________________________________________
#
# Verify compatiblity.
# _____________________________________________________________________________________________
if (node['platform'] == 'ubuntu') & (node['platform_version'] >= '16') & (node['kubernetes-cluster']['k8s-version'] == '1.7')
else
  Chef::Log.info('OS Compatibility issue.')
  return
end
# _____________________________________________________________________________________________
#
# Change master node hostname.
# _____________________________________________________________________________________________
ruby_block 'allow_to_change_hostname' do
  block do
    file = Chef::Util::FileEdit.new('/etc/cloud/cloud.cfg')
    file.insert_line_if_no_match(/^preserve_hostname:\s*true.*/, 'preserve_hostname: true')
    file.search_file_replace_line(/^preserve_hostname:\s*true.*/, 'preserve_hostname: true')
    file.write_file
  end
  only_if { ::File.exist?('/etc/cloud/cloud.cfg') }
  not_if { ::File.readlines('/etc/cloud/cloud.cfg').grep(/^preserve_hostname:\s*true/).any? }
end

package %w(telnet ntp) do
    action :install
    version [ '0.17-40', '' ]
end
# _____________________________________________________________________________________________
#
# Generates yum_repository configs for latest CentOS release.
# By default the base, extras, updates repos are enabled.
# _____________________________________________________________________________________________
bash 'Add key for new repository' do
  code <<-EOH
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    EOH
end
bash 'add repository' do
  code <<-EOH
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    EOH
    not_if { ::File.exist?('/etc/apt/sources.list.d/kubernetes.list') }
end
# _____________________________________________________________________________________________
#
# To install following packages.
# Package list - docker kubelet kubeadm kubectl kubernetes-cni
# _____________________________________________________________________________________________
package %w(kubelet kubeadm kubectl kubernetes-cni docker.io) do
    action :install
    version [ '1.7.3-01', '1.7.3-01', '1.7.3-01', '0.5.1-00', '1.12.6-0ubuntu1~16.04.1' ]
end
# _____________________________________________________________________________________________
#
# To enable and start docker kubelet ntp services.
# _____________________________________________________________________________________________
service 'ntp' do
  pattern 'ntp'
  action [:enable, :start]
end

service 'docker' do
  pattern 'docker'
  action [:enable, :start]
end

service 'kubelet' do
  pattern 'kubelet'
  action [:enable, :start]
end
#_____________________________________________________________________________________________
#
# Adding hostname entry in hosts file
#_____________________________________________________________________________________________
ruby_block 'adding_masternode_entry' do
  block do
    file = Chef::Util::FileEdit.new('/etc/hosts')
    file.insert_line_if_no_match(/^#{node['kubernetes-cluster']['ipaddress']}.*/,  "#{node['kubernetes-cluster']['ipaddress']} #{node['kubernetes-cluster']['hostname']}")
    file.search_file_replace_line(/^#{node['kubernetes-cluster']['ipaddress']}.*/, "#{node['kubernetes-cluster']['ipaddress']} #{node['kubernetes-cluster']['hostname']}")
    file.write_file
  end
  only_if { ::File.exist?('/etc/hosts') }
  not_if { ::File.readlines('/etc/hosts').grep(/^#{node['kubernetes-cluster']['ipaddress']}\s*#{node['kubernetes-cluster']['hostname']}/).any? }
end
# _____________________________________________________________________________________________
#
# Join kubernetes cluster using kubeadm command with kube master token.
# _____________________________________________________________________________________________
bash 'creating kubernetes cluster' do
  code <<-EOH
    kubeadm join --token #{node['kubernetes-cluster']['token']} #{node['kubernetes-cluster']['ipaddress']}:#{node['kubernetes-cluster']['kube-apiserver']} --skip-preflight-checks
    EOH
  not_if { ::File.exist?('/etc/kubernetes/kubelet.conf') }
end