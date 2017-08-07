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
if (node['platform'] == 'centos') & (node['platform_version'] >= '7') & (node['kubernetes-cluster']['k8s-version'] == '1.7')
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
# _____________________________________________________________________________________________
#
# Adding hostname entry in hosts file
# _____________________________________________________________________________________________
ruby_block 'adding_masternode_entry' do
  block do
    file = Chef::Util::FileEdit.new('/etc/hosts')
    file.insert_line_if_no_match(/^#{node['ipaddress']}.*/,  "#{node['ipaddress']} #{node['kubernetes-cluster']['hostname']}")
    file.search_file_replace_line(/^#{node['ipaddress']}.*/, "#{node['ipaddress']} #{node['kubernetes-cluster']['hostname']}")
    file.write_file
  end
  only_if { ::File.exist?('/etc/hosts') }
  not_if { ::File.readlines('/etc/hosts').grep(/^#{node['ipaddress']}\s*#{node['kubernetes-cluster']['hostname']}/).any? }
end

bash 'creating kubernetes cluster' do
  code <<-EOH
      hostnamectl set-hostname "#{node['kubernetes-cluster']['hostname']}"
    EOH
end
# _____________________________________________________________________________________________
#
# Execute 2 part of this recipe after reboot
# _____________________________________________________________________________________________
cron 'chef-client' do
  time :reboot
  command 'cd /tmp/kitchen/cookbooks/ &  sudo chef-client -z -o kubernetes-cluster::default > /tmp/out.log'
  user 'centos'
  only_if { ::File.exists?('/tmp/kitchen/cookbooks/kubernetes-cluster')}
end

# _____________________________________________________________________________________________
#
# Generates yum_repository configs for latest CentOS release.
# By default the base, extras, updates repos are enabled.
# _____________________________________________________________________________________________
yum_repository 'kubernetes' do
  description "CentOS-#{node['platform_version'].to_i} - Base"
  baseurl 'http://yum.kubernetes.io/repos/kubernetes-el7-x86_64'
  enabled true
  gpgcheck false
  repo_gpgcheck false
  action :create
end
# _____________________________________________________________________________________________
#
# To install following packages.
# Package list - docker kubelet kubeadm kubectl kubernetes-cni wget vim ntp
# _____________________________________________________________________________________________
%w(telnet docker kubelet kubeadm kubectl kubernetes-cni ntp).each do |pkg|
  yum_package pkg do
    action :install
  end
end
# _____________________________________________________________________________________________
#
# Disable Selinux security.
# _____________________________________________________________________________________________
ruby_block 'disable_selinux' do
  block do
    file = Chef::Util::FileEdit.new('/etc/selinux/config')
    file.search_file_replace_line(/^SELINUX=.*/, 'SELINUX=disabled')
    file.write_file
  end
  not_if 'grep -E "SELINUX.*=.*disabled.*" /etc/selinux/config'
end
# _____________________________________________________________________________________________
#
# To enable and start docker kubelet ntp services.
# _____________________________________________________________________________________________
service 'ntpd' do
  pattern 'ntpd'
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

reboot 'now' do
  action :nothing
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
  not_if { ::File.readlines('/etc/hosts').grep(/^#{node['kubernetes-cluster']['ipaddress']}\s*#{node['kubernetes-cluster']['hostname']}/).any?}
  notifies :reboot_now, 'reboot[now]', :immediately
end
bash 'creating kubernetes cluster' do
  code <<-EOH
      hostnamectl set-hostname "#{node['kubernetes-cluster']['hostname']}"
    EOH
end
# _____________________________________________________________________________________________
#
# Start to create kubernetes cluster.
# _____________________________________________________________________________________________
bash 'creating kubernetes cluster' do
  code <<-EOH
      kubeadm init --token-ttl 0 > /tmp/output.log
    EOH
  not_if { ::File.exist?('/etc/kubernetes/admin.conf') }
end
# _____________________________________________________________________________________________
#
# Verify All required ports are open or not.
# _____________________________________________________________________________________________
ruby_block 'kubelet' do
  block do
    server = node['kubernetes-cluster']['localhost']
    port = node['kubernetes-cluster']['kubelet']
    begin
      Timeout.timeout(5) do
        Socket.tcp(server, port) {}
      end
      Chef::Log.info "kubelet=#{node['kubernetes-cluster']['kubelet']} connections open"
    rescue
      Chef::Log.fatal "kubelet=#{node['kubernetes-cluster']['kubelet']} connections refused"
    end
  end
end

ruby_block 'kube-scheduler' do
  block do
    server = node['kubernetes-cluster']['localhost']
    port = node['kubernetes-cluster']['kube-scheduler']
    begin
      Timeout.timeout(5) do
        Socket.tcp(server, port) {}
      end
      Chef::Log.info "kube-scheduler=#{node['kubernetes-cluster']['kube-scheduler']} connections open"
    rescue
      Chef::Log.fatal "kube-scheduler=#{node['kubernetes-cluster']['kube-scheduler']} connections refused"
    end
  end
end

ruby_block 'kube-controlle' do
  block do
    server = node['kubernetes-cluster']['localhost']
    port = node['kubernetes-cluster']['kube-controlle']
    begin
      Timeout.timeout(5) do
        Socket.tcp(server, port) {}
      end
      Chef::Log.info "kube-controlle=#{node['kubernetes-cluster']['kube-controlle']} connections open"
    rescue
      Chef::Log.fatal "kube-controlle=#{node['kubernetes-cluster']['kube-controlle']} connections refused"
    end
  end
end

ruby_block 'kube-proxy' do
  block do
    server = node['kubernetes-cluster']['localhost']
    port = node['kubernetes-cluster']['kube-proxy']
    begin
      Timeout.timeout(5) do
        Socket.tcp(server, port) {}
      end
      Chef::Log.info "kube-proxy=#{node['kubernetes-cluster']['kube-proxy']} connections open"
    rescue
      Chef::Log.fatal "kube-proxy=#{node['kubernetes-cluster']['kube-proxy']} connections refused"
    end
  end
end

ruby_block 'kube-apiserver' do
  block do
    server=node['kubernetes-cluster']['localhost']
    port=node['kubernetes-cluster']['kube-apiserver']
    begin
      Timeout.timeout(5) do
        Socket.tcp(server, port) {}
      end
      Chef::Log.info "kube-apiserver=#{node['kubernetes-cluster']['kube-apiserver']} connections open"
    rescue
      Chef::Log.fatal "kube-apiserver=#{node['kubernetes-cluster']['kube-apiserver']} connections refused"
    end
  end
end

ruby_block 'etcd' do
  block do
    server = node['kubernetes-cluster']['localhost']
    port = node['kubernetes-cluster']['etcd']
    begin
      Timeout.timeout(5) do
        Socket.tcp(server, port) {}
      end
      Chef::Log.info "etcd=#{node['kubernetes-cluster']['etcd']} connections open"
    rescue
      Chef::Log.fatal "etcd=#{node['kubernetes-cluster']['etcd']} connections refused"
    end
  end
end
# _____________________________________________________________________________________________
#
# configure weave network for kube cluster.
# _____________________________________________________________________________________________
directory '/etc/weave-networking' do
  owner 'root'
  group 'root'
  mode '644'
  action :create
end

cookbook_file '/etc/weave-networking/weave-network.yaml' do
  source 'weave-network.yaml'
  owner 'root'
  group 'root'
  mode '644'
  action :create
end

bash 'Set KUBECONFIG' do
  code <<-EOH
    sudo cp /etc/kubernetes/admin.conf $HOME/
    sudo chown $(id -u):$(id -g) $HOME/admin.conf
    export KUBECONFIG=$HOME/admin.conf
    kubectl apply --filename "/etc/weave-networking/weave-network.yaml"
    EOH
  not_if 'ifconfig | grep weave'
end
