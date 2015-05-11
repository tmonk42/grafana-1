#
# Cookbook Name:: grafana
# Recipe:: _install_file
#
# Copyright 2014, Grégoire Seux
# Copyright 2014, Jonathan Tron
# Copyright 2015, Michael Lanyon
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform_family']
when 'debian'
  pkgs = %w(adduser libfontconfig)
  pkgs.each do |pkg|
    package pkg
  end

  remote_file "#{Chef::Config[:file_cache_path]}/grafana-#{node['grafana']['file']['version']}.deb" do
    source "https://grafanarel.s3.amazonaws.com/builds/grafana_#{node['grafana']['file']['version']}_amd64.deb"
    action :create
    not_if { 'dpkg --get-selections | grep grafana' }
  end

  dpkg_package "grafana-#{node['grafana']['file']['version']}" do
    source "#{Chef::Config[:file_cache_path]}/grafana-#{node['grafana']['file']['version']}.deb"
    action :install
  end
when 'rhel'
  pkgs = %w(initscripts fontconfig)
  pkgs.each do |pkg|
    package pkg
  end

  remote_file "#{Chef::Config[:file_cache_path]}/grafana-#{node['grafana']['file']['version']}.rpm" do
    source "https://grafanarel.s3.amazonaws.com/builds/grafana-#{node['grafana']['file']['version']}-1.x86_64.rpm"
    action :create
    # not_if { '' }
  end

  rpm_package "grafana-#{node['grafana']['file']['version']}" do
    source "#{Chef::Config[:file_cache_path]}/grafana-#{node['grafana']['file']['version']}.rpm"
    action :install
  end
end
