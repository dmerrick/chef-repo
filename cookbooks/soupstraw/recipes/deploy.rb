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

# create the following directories:
[
  node[:soupstraw][:deploy_dir],
  "#{node[:soupstraw][:docroot]}/vendor",
  "#{node[:soupstraw][:shared_dir]}/config"
].each do |dir|
  directory dir do
    owner deploy_user
    group deploy_user
    recursive true
  end
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

# pull down new code from git
deploy_revision node[:soupstraw][:deploy_dir] do
  repo node[:soupstraw][:repository]
  revision node[:soupstraw][:branch]
  user deploy_user
  group deploy_user
  create_dirs_before_symlink %w{log config tmp/pids tmp/sockets}
  symlinks "tmp/pids" => "tmp/pids",
           "log"  => "log"
  symlink_before_migrate "config/database.yml" => "config/database.yml"


  # this stuff is pretty rails-specific, so disable it
  purge_before_symlink.clear

  action :deploy
  notifies :run, "rbenv_execute[run bundle install]", :immediately
  notifies :run, "rbenv_execute[migrate the database]", :immediately
  notifies :reload, "service[unicorn]"
end

# install the necessary gems
#TODO: try and see if we can avoid the rbenv_execute resource
rbenv_execute "run bundle install" do
  command "#{node[:soupstraw][:bundle_binary]} install --deployment --binstubs"
  cwd node[:soupstraw][:docroot]
  ruby_version node[:soupstraw][:ruby_version]
  user deploy_user
  action :nothing
end

# run database migrations
#TODO: try and see if we can avoid the rbenv_execute resource
rbenv_execute "migrate the database" do
  command "#{node[:soupstraw][:bundle_binary]} exec rake db:migrate"
  environment "RACK_ENV" => node.chef_environment
  cwd node[:soupstraw][:docroot]
  ruby_version node[:soupstraw][:ruby_version]
  user deploy_user
  action :nothing
end
