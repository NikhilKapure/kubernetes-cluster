name 'kubernetes-cluster'
maintainer 'Nikhil S. Kapure'
maintainer_email 'nikhil.kapure@reancloud.com'
license 'All Rights Reserved'
description 'Installs/Configures Kubernetes-Cluster'
long_description 'Installs/Configures Kubernetes-Cluster'
version '0.1.3'
chef_version '>= 12.1' if respond_to?(:chef_version)
supports 'centos', '>= 7'

issues_url 'https://github.com/reancloud/deploynow-blueprintsl/issues' if respond_to?(:issues_url)
source_url 'https://github.com/reancloud/deploynow-blueprints' if respond_to?(:source_url)
# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/Kubernetes-Cluster/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/Kubernetes-Cluster'
