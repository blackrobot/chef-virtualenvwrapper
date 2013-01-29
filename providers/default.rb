#
# Cookbook Name:: virtualenvwrapper
# Provider:: default
#
# Copyright:: Copyright (c) 2013, Damon Jablons
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

action :create do
  bash "create_virtualenv" do
    user new_resource.owner
    group new_resource.group if new_resource.group
    action :run

    code <<-EOH
      source #{node[:virtualenvwrapper][:script]} && \
        mkvirtualenv #{new_resource.name}
    EOH
    environment({ 'WORKON_HOME' => node['virtualenvwrapper']['workon_home'] })
    creates virtualenv_path
  end
end

action :destroy do
  directory virtualenv_path do
    recursive true
    action :delete
  end
end

action :install do
  if new_resource.requirements
    Chef::Log.info("Installing from requirements file")
    install_from_file
  elsif new_resource.packages
    Chef::Log.info("Installing from packages")
    install_from_packages
  else
    Chef::Log.debug("No requirements or packages found")
  end
end

def install_from_file
  pip_cmd = ::File.join(node['virtualenvwrapper']['workon_home'],
                        new_resource.name, "bin", "pip")
  execute "#{pip_cmd} install -r #{new_resource.requirements}" do
    action :run
  end
end

def install_from_packages
  new_resource.packages.each do |name, ver|
    python_pip name do
      version ver if ver && ver.length > 0
      virtualenv virtualenv_path
      action :install
    end
  end
end

def virtualenv_path
  ::File.join(node['virtualenvwrapper']['workon_home'], new_resource.name)
end
