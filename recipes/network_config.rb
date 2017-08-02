#
# Cookbook:: Kubernetes-Cluster
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

bash 'Set KUBECONFIG' do
  code <<-EOH
    sudo cp /etc/kubernetes/admin.conf $HOME/
    sudo chown $(id -u):$(id -g) $HOME/admin.conf
    export KUBECONFIG=$HOME/admin.conf
    EOH
end

directory '/etc/weave-networking' do
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

cookbook_file '/etc/weave-networking/weave-network.yaml' do
  source 'weave-network.yaml'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

bash 'configure weave network' do
  code <<-EOH
    kubectl apply --filename "/etc/weave-networking/weave-network.yaml"
    EOH
  #not_if "#{node['network']['interfaces']['weave']}"
  not_if "ifconfig | grep weave"
end

ruby_block "weave-npc" do
  block do
    server = "#{node['kubernetes-cluster']['localhost']}"
    port = "#{node['kubernetes-cluster']['weave-npc']}"
    begin
      Timeout.timeout(5) do
        Socket.tcp(server, port){}
      end
      Chef::Log.info "weave-npc=#{node['kubernetes-cluster']['weave-npc']} connections open"
    rescue
      Chef::Log.fatal "weave-npc=#{node['kubernetes-cluster']['weave-npc']} connections refused"
    end
  end
end

ruby_block "weaver" do
  block do
    server = "#{node['kubernetes-cluster']['localhost']}"
    port = "#{node['kubernetes-cluster']['weaver']}"
    begin
      Timeout.timeout(5) do
        Socket.tcp(server, port){}
      end
      Chef::Log.info "weaver=#{node['kubernetes-cluster']['weaver']} connections open"
    rescue
      Chef::Log.fatal "weaver=#{node['kubernetes-cluster']['weaver']} connections refused"
    end
  end
end
