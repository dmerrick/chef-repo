#
# Cookbook Name:: soupstraw
# Recipe:: deploy
#
# Copyright (C) 2013 Soupstraw, Inc.
#

include_recipe 'soupstraw::ruby'
#include_recipe 'apache2'
include_recipe 'git'


app_name = node[:soupstraw][:server_name]
deploy_user = node[:apache][:user]


# create directory if required
directory node[:soupstraw][:deploy_dir] do
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

# Use the magical deploy_resource module in chef
deploy_revision node[:soupstraw][:deploy_dir] do
  repo node[:soupstraw][:repository]
  revision node[:soupstraw][:branch]
  user deploy_user
  group deploy_user

  symlink_before_migrate.clear
  create_dirs_before_symlink.clear
  purge_before_symlink.clear
  symlinks.clear

  action :deploy
  #notifies :restart, "service[apache2]"
  notifies :restart, "service[unicorn]"
end

[
  "#{node[:soupstraw][:shared_dir]}/config",
  "#{node[:soupstraw][:shared_dir]}/log",
  "#{node[:soupstraw][:docroot]}/vendor",
  "#{node[:soupstraw][:docroot]}/tmp/pids"
].each do |dir|
  directory dir do
    owner deploy_user
    group deploy_user
    recursive true
  end
end

# create symlink so logs dir is shared across releases
link "#{node[:soupstraw][:docroot]}/log" do
  to "#{node[:soupstraw][:shared_dir]}/log"
  owner deploy_user
  group deploy_user
end

# create database.yml
#FIXME: most of this should be in attributes
#FIXME: create soupstraw_ENV database
#TODO: find postgres-y options to pass
template "#{node[:soupstraw][:shared_dir]}/config/database.yml" do
  source 'database.yml.erb'
  owner deploy_user
  group deploy_user
  mode 0644
  variables(
    :environment => node.chef_environment,
    :adapter     => 'postgresql',
    :database    => 'postgres', # "soupstraw_#{node.chef_environment}",
    :username    => 'postgres',
    :password    => node[:postgresql][:password][:postgres],
    :host        => 'localhost' # fixme
  )
end

# make the shared database.yml accessible to the app
link "#{node[:soupstraw][:docroot]}/config/database.yml" do
  to "#{node[:soupstraw][:shared_dir]}/config/database.yml"
  owner deploy_user
  group deploy_user
end

#TODO: make idempotent
rbenv_execute "run bundle install" do
  command "/opt/rbenv/shims/bundle install --deployment --binstubs"
  cwd node[:soupstraw][:docroot]
  ruby_version node[:soupstraw][:ruby_version]
  user deploy_user
end

#FIXME: is there a better place to call this?
#TODO: make idempotent
rbenv_execute "migrate the database" do
  command "/opt/rbenv/shims/bundle exec rake db:migrate"
  cwd node[:soupstraw][:docroot]
  ruby_version node[:soupstraw][:ruby_version]
  user deploy_user
end

#FIXME: hacky
#bash "repair permissions on #{node[:soupstraw][:deploy_dir]}" do
#  code "chown -R #{deploy_user}:#{deploy_user} #{node[:soupstraw][:deploy_dir]}"
#end
