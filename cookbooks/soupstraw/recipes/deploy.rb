#
# Cookbook Name:: soupstraw
# Recipe:: deploy
#
# Copyright (C) 2013 Soupstraw, Inc.
#

include_recipe 'soupstraw::ruby'
include_recipe 'git' #FIXME: is this necessary?

app_name = node[:soupstraw][:server_name]
deploy_user = node[:soupstraw][:deploy_user]

# create /data directory if required
directory node[:soupstraw][:deploy_dir] do
  owner deploy_user
  group deploy_user
  action :create
  recursive true
end

# pull down new code from git
deploy_revision node[:soupstraw][:deploy_dir] do
  repo node[:soupstraw][:repository]
  revision node[:soupstraw][:branch]
  user deploy_user
  group deploy_user

  # this stuff is pretty rails-specific, so disable it
  symlink_before_migrate.clear
  create_dirs_before_symlink.clear
  purge_before_symlink.clear
  symlinks.clear

  action :deploy
  notifies :restart, "service[unicorn]"
end

# create the following directories:
[
  "#{node[:soupstraw][:shared_dir]}/config",
  "#{node[:soupstraw][:shared_dir]}/log",
  "#{node[:soupstraw][:docroot]}/vendor",
  "#{node[:soupstraw][:docroot]}/tmp/pids",
  "#{node[:soupstraw][:docroot]}/tmp/sockets"
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
#FIXME: figure out how to create soupstraw_ENV database
#TODO: find postgres-y options to pass
#TODO: use chef search to set the host value
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
    :host        => 'localhost'
  )
end

# make the shared database.yml accessible to the app
link "#{node[:soupstraw][:docroot]}/config/database.yml" do
  to "#{node[:soupstraw][:shared_dir]}/config/database.yml"
  owner deploy_user
  group deploy_user
end

# install the necessary gems
#TODO: make idempotent
#TODO: try and see if we can avoid the rbenv_execute resource
rbenv_execute "run bundle install" do
  command "/opt/rbenv/shims/bundle install --deployment --binstubs"
  cwd node[:soupstraw][:docroot]
  ruby_version node[:soupstraw][:ruby_version]
  user deploy_user
end

# run database migrations
#TODO: make idempotent
#TODO: try and see if we can avoid the rbenv_execute resource
rbenv_execute "migrate the database" do
  command "/opt/rbenv/shims/bundle exec rake db:migrate"
  environment "RACK_ENV" => node.chef_environment
  cwd node[:soupstraw][:docroot]
  ruby_version node[:soupstraw][:ruby_version]
  user deploy_user
end
