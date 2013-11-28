#
# Cookbook Name:: soupstraw
# Recipe:: deploy
#
# Copyright (C) 2013 Soupstraw, Inc.
#

include_recipe 'soupstraw::ruby'
include_recipe 'git' #FIXME: is this necessary?

# required to install the pg gem
package 'libpq-dev'

app_name = node[:soupstraw][:server_name]
deploy_user = node[:soupstraw][:deploy_user]

# create the following directories:
[
  node[:soupstraw][:deploy_dir],
  node[:soupstraw][:shared_dir],
  "#{node[:soupstraw][:docroot]}/vendor",
  "#{node[:soupstraw][:shared_dir]}/bundle",
  "#{node[:soupstraw][:shared_dir]}/bin",
  "#{node[:soupstraw][:shared_dir]}/config"
].each do |dir|
  directory dir do
    owner deploy_user
    group deploy_user
    recursive true
  end
end

bash 'ensure docroot is owned by deploy user' do
  code "chown #{deploy_user}:#{deploy_user} #{node[:soupstraw][:docroot]}"
  only_if { File.exists?(node[:soupstraw][:docroot]) }
end

# create database.yml
#FIXME: most of this should be in attributes
#FIXME: figure out how to create soupstraw_ENV database
#TODO: find postgres-y options to pass
#TODO: add encoding: 'utf8'
#TODO: move me to a config_files recipe
postgres_master = search(:node, "role:db_server AND chef_environment:#{node.chef_environment}").first
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
    :host        => postgres_master['fqdn']
  )
end


# load the home server data bag
home_server = data_bag_item('servers', 'home')

# create application.yml
#TODO: move me to a config_files recipe
template "#{node[:soupstraw][:shared_dir]}/config/application.yml" do
  source 'application.yml.erb'
  owner deploy_user
  group deploy_user
  mode 0644
  variables(
    :environment   => node.chef_environment,
    :default_path  => node[:soupstraw][:default_path],
    :cookie_secret => node[:soupstraw][:cookie_secret],
    :home_url      => home_server['url'],
    :home_username => home_server['username'],
    :home_password => home_server['password']
  )
end

# pull down new code from git
# only runs if /data/soupstraw/current does not yet exist
deploy_revision node[:soupstraw][:deploy_dir] do
  repo node[:soupstraw][:repository]
  revision node[:soupstraw][:branch]
  user deploy_user
  group deploy_user
  create_dirs_before_symlink %w{log config tmp/pids tmp/sockets}
  symlinks "tmp/pids" => "tmp/pids",
           "log"      => "log"
  symlink_before_migrate "config/database.yml" => "config/database.yml",
                         "config/application.yml" => "config/application.yml"

  # this stuff is pretty rails-specific, so disable it
  purge_before_symlink.clear

  action :deploy
  notifies :run, "rbenv_execute[run bundle install]", :immediately
  notifies :run, "rbenv_execute[migrate the database]", :immediately
  #FIXME: this doesnt work on utility servers since they don't have unicorn
  #notifies :reload, "service[unicorn]"

  # don't run if we already have a deploy
  not_if { File.exists?(node[:soupstraw][:docroot]) }
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
