#
# Cookbook Name:: gerrit
# Recipe:: default
#

include_recipe "java"
include_recipe "mysql::server"
include_recipe "database"

mysql_connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

node.set_unless['mysql']['gerrit_user_password']   = secure_password

# Create gerrit system user
user "gerrit2" do
  comment "Gerrit User"
  system true
  shell "/bin/false"
end

# Create gerrit directory
directory node['gerrit']['path'] do
  owner "gerrit2"
  group "sys"
  mode "0755"
  action :create
end

# Create reviewdb mysql database
mysql_database 'reviewdb' do
  connection mysql_connection_info
  action :create
end

# Create gerrit mysql user
mysql_database_user "gerrit2" do
  connection mysql_connection_info
  password node['mysql']['gerrit_user_password']
  database_name "reviewdb"
  host '%'
  action :grant
end


# Fugly, but the developers of gerrit haven't made it available in any
# other format

war_name = "gerrit-#{node['gerrit']['version']}.war"
remote_file "#{Chef::Config['file_cache_path']}/#{war_name}" do
  source "http://gerrit.googlecode.com/files/#{war_name}"
  notifies :run, 'bash[install_gerrit]', :immediately
end

bash 'install_gerrit' do
  user 'gerrit2'
  cwd Chef::Config['file_cache_path']
  code <<-EOH
      java -jar #{war_name} init -d #{node['gerrit']['path']}
    EOH
  action :nothing
end
