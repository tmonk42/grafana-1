name             'grafana'
maintainer       'Sous Chefs'
maintainer_email 'help@sous-chefs.org'
license          'Apache-2.0'
description      'Installs/Configures Grafana Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://github.com/sous-chefs/chef-grafana'
issues_url       'https://github.com/sous-chefs/chef-grafana/issues'
chef_version     '>= 13.0'
version          '5.0.0'

supports 'debian'
supports 'ubuntu'
supports 'redhat'
supports 'centos'
supports 'fedora'
supports 'amazon'
supports 'scientific'
supports 'oracle'
