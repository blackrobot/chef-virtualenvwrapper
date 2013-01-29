#
# Cookbook Name:: virtualenvwrapper
# Recipe:: default
#
# Copyright 2013, Damon Jablons
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

include_recipe "python"

workon_home = node['virtualenvwrapper']['workon_home']
user_name = node['virtualenvwrapper']['user']
user_profile = node['virtualenvwrapper']['profile']

python_pip "virtualenvwrapper" do
  action :install
end

# Create the workon home directory
directory workon_home do
  owner user_name
  group node['virtualenvwrapper']['group']
  mode 0755
  recursive true
end

# Add variables to user profile
[ "export WORKON_HOME='#{workon_home}'",
  "source '#{node['virtualenvwrapper']['script']}'" ].each do |line|
  ruby_block "insert_line" do
    block do
      file = Chef::Util::FileEdit.new(user_profile)
      file.insert_line_if_no_match("/#{line}/", line)
      file.write_file
    end
  end
end

bash "setup_virtualenvwrapper" do
  code "su #{user_name} -l -c 'source #{user_profile}'"
  action :run
end
