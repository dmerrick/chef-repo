#
# Cookbook Name:: soupstraw
# Recipe:: application
#
# Copyright (C) 2013 Soupstraw, Inc.
# 

#directory '/root/.config/git' do
#  recursive true
#end
#
#file '/root/.config/git/config'

#include_recipe "rbenv::default"
#include_recipe "rbenv::ruby_build"
#rbenv_ruby "2.0.0"


include_recipe 'apache2'
include_recipe 'git'


app_name = node[:soupstraw][:server_name]
deploy_user = node[:apache][:user]


# create directory if required
directory "#{node[:soupstraw][:deploy_dir]}" do
  owner deploy_user
  group deploy_user
  action :create
  recursive true
end

# create vhost
#web_app app_name do
#  server_name app_name
#  docroot node[:soupstraw][:docroot]
#  template "sinatra_app.conf.erb"
#  log_dir node[:apache][:log_dir]
#end


#gem_package "sinatra" do
#  action :install
#end

# Use the magical deploy_resource module in chef
deploy_revision node[:soupstraw][:deploy_dir] do
  scm_provider Chef::Provider::Git
  repo node[:soupstraw][:repository]
  revision node[:soupstraw][:branch]
  symlink_before_migrate.clear
  create_dirs_before_symlink.clear
  purge_before_symlink.clear
  symlinks.clear
  #user deploy_user
  #group deploy_user
    
  action :deploy
  notifies :restart, "service[apache2]"
end

bash "repair permissions on #{node[:soupstraw][:deploy_dir]}" do
  code "chown -R #{deploy_user}:#{deploy_user} #{node[:soupstraw][:deploy_dir]}"
end

directory "#{node[:soupstraw][:deploy_dir]}/shared/config" do
  recursive true
end

unicorn_ng_config "#{node[:soupstraw][:deploy_dir]}/shared/config/unicorn.rb" do
  worker_processes 16 if node.chef_environment == 'production'
  worker_processes  2 if node.chef_environment == 'development'

  case node.chef_environment
  when 'production'
    # We may be started by root, thus dropping privileges
    user deploy_user
    working_directory node[:soupstraw][:docroot]

    # Listen on UNIX domain socket only
    # Shorter backlog for quicker failover when busy
    listen  'unix:tmp/sockets/unicorn.sock'
    backlog 1024

  when 'development'
    listen '8080'
  end

  # Kill workers after 30 seconds on production
  timeout (node.chef_environment == 'production' ? 30 : 60)
end

gem_package "bundler"

unicorn_ng_service node[:soupstraw][:docroot] do
  bundle '/usr/local/bin/bundle'
end

service 'unicorn' do
  action :start
end
