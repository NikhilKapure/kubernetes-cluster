# kubernetes-cluster

Resources for deploying various Kubernetes entities, these resources are designed to be ran on the kubernetes master but can be ran anywhere.

Currently supported resources:

  * Kubernetes Master (`kube_master`)
  * Kubernetes Node (`kube_worker`)

OS Support: 

  * Supported for platform_family=RHEL v7+
  * Kubernetes 1.7 only for now. 

# Attributes

  * `['kubernetes-cluster']['localhost'] = '127.0.0.1' - This IP require for checking respective kubernetes port
  * `['kubernetes-cluster']['hostname'] = 'kubemaster' **required** - Hostname for Master node
  * `['kubernetes-cluster']['ipaddress'] = '' **required** - The private ip address of your kubernetes master. its require for worker to connect kubenetes master
  * `['kubernetes-cluster']['kubelet'] = '10255' - Non-changeble. This used only for port verification.  
  * `['kubernetes-cluster']['kube-scheduler'] = '10251' - Non-changeble. This used only for port verification.
  * `['kubernetes-cluster']['kube-controlle'] = '10252' - Non-changeble. This used only for port verification.
  * `['kubernetes-cluster']['kube-proxy'] = '10256' - Non-changeble. This used only for port verification.
  * `['kubernetes-cluster']['kube-apiserver'] = '6443' - Non-changeble. This used only for port verification. its require for worker to connect kubenetes master
  * `['kubernetes-cluster']['etcd'] = '2380'- Non-changeble. This used only for port verification.
  * `['kubernetes-cluster']['weave-npc'] = '6781' - Non-changeble. This used only for port verification.
  * `['kubernetes-cluster']['weaver'] = '6782' - Non-changeble. This used only for port verification.
  * `['kubernetes-cluster']['k8s-version'] = '1.7' - Version of kubernetes
  * `['kubernetes-cluster']['token'] = '7de59e.b859a71e082d41a5' **required** - Provide a token after your master node ready. its require for worker to connect kubenetes master
  * `['kubernetes-cluster']['agent'] = 'master' **required** - Select setup agent [worker/master]

# Recipes

#### default
This is a default recipe. it will automatically execute respective recipe as per the if condition and parameters. 

#### kube_master_centos_1.7 (`Kube_Master`)
1. Configure master node hostname.
2. Disable selinux security. 
3. Installing all require package for kuber master. 
4. Enable and Start all require service. **Reboot after**
5. Create Kubernetes cluster.
6. Verify all respective port for kube connection. 
7. Deploy the containers needed to make a functioning Kubernetes node that can attach to a remote master. This will deploy weave and the needed kubernetes services.

Ensures the needed containers for a kubernetes master are deployed/running with proper networking setup.
Deploy the containers needed to make a functioning Kubernetes master locally on the system. This will deploy etcd, api-server, kube-scheduler, kube-controlle, and all needed kubernetes services.

#### kube_worker_centos_1.7 (`Kube_Worker`)
1. Resolving maste node hostname locally.
2. Disable selinux security. 
3. Installing all require package for kuber worker. 
4. Enable and Start all require service.
5. Joining kube-cluster using Kubeadm tool. 

Ensures the needed containers for a kubernetes node are in place and running

Design document and Sequence diagram - 
 https://reancloud.atlassian.net/wiki/spaces/PLAT/pages/153844550/DEP-4341+Kubernetes+cluster+deploy+and+config+blueprint
# License and Author

* Author:: Nikhil S. Kapure (<nikhil.kapure@reancloud.com>)