#
# Cookbook:: grafana
# Resource:: config
#
# Copyright:: 2014, Jonathan Tron
# Copyright:: 2017, Andrei Skopenko
# Copyright:: 2018, Sous Chefs
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
# Configures the installed grafana instance

property  :instance_name,       String, name_property: true
property  :env_directory,       String, default: '/etc/default'
property  :owner,               String, default: 'grafana'
property  :group,               String, default: 'grafana'
property  :restart_on_upgrade,  String, default: 'false'
property  :conf_directory,      String, default: '/etc/grafana'
property  :config_file,         String, default: lazy { ::File.join(conf_directory, 'grafana.ini') }
property  :app_mode,            String, default: 'production', equal_to: %w(production development)
property  :cookbook,            String, default: 'grafana'
property  :source,              String, default: 'grafana.ini.erb'

action :install do
  user new_resource.owner

  group new_resource.group

  directory new_resource.conf_directory do
    owner new_resource.owner
    group new_resource.group
    mode  '0750'
  end

  service 'grafana-server' do
    action :enable
    subscribes :restart, "template[#{::File.join(new_resource.env_directory, 'grafana-server')}]", :immediately
  end

  directory "/usr/share/#{new_resource.owner}" do
    owner     new_resource.owner
    group     new_resource.group
    mode      '0750'
    recursive true
  end

  template ::File.join(new_resource.env_directory, 'grafana-server') do
    source 'grafana-env.erb'
    variables(
      grafana_user: new_resource.owner,
      grafana_group: new_resource.group,
      grafana_home: "/usr/share/#{new_resource.owner}",
      conf_dir: new_resource.conf_directory,
      pid_dir: '/var/run/grafana',
      restart_on_upgrade: new_resource.restart_on_upgrade
    )
    cookbook new_resource.cookbook
    mode '0644'
  end

  with_run_context :root do
    edit_resource(:template, new_resource.config_file) do |new_resource|
      node.run_state['grafana'] ||= { 'conf_template_source' => {}, 'conf_cookbook' => {} }
      source new_resource.source
      cookbook new_resource.cookbook
      variables['grafana'] ||= {}

      variables['grafana']['instance_name'] ||= '' unless new_resource.instance_name.nil?
      variables['grafana']['instance_name'] << new_resource.instance_name.to_s unless new_resource.instance_name.nil?
      variables['grafana']['app_mode'] ||= '' unless new_resource.app_mode.nil?
      variables['grafana']['app_mode'].<< new_resource.app_mode.to_s unless new_resource.app_mode.nil?

      action :nothing
      delayed_action :create
      service 'grafana-server'
      notifies :restart, 'service[grafana-server]'
    end
  end
end
