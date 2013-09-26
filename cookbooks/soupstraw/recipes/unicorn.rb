#
# Cookbook Name:: soupstraw
# Recipe:: unicorn
#
# Copyright (C) 2013 Soupstraw, Inc.
#

deploy_user = node[:soupstraw][:deploy_user]

unicorn_ng_config "#{node[:soupstraw][:shared_dir]}/config/unicorn.rb" do
  # this can be bumped if we move off t1.micros
  worker_processes 2 if node.chef_environment == 'production'
  worker_processes 1 if node.chef_environment == 'development'

  working_directory node[:soupstraw][:docroot]

  user  deploy_user
  owner deploy_user
  group deploy_user

  # listen on UNIX domain socket only
  listen 'unix:tmp/sockets/unicorn.sock'

  # shorter backlog for quicker failover when busy
  backlog 1024 if node.chef_environment == 'production'

  # this is to fix a bug where verify_active_connections! did not exist
  #TODO: perhaps investigate adding it back later?
  after_fork.clear

  # kill workers after 30 seconds on production
  timeout (node.chef_environment == 'production' ? 30 : 60)
end

unicorn_ng_service node[:soupstraw][:docroot] do
  config "#{node[:soupstraw][:shared_dir]}/config/unicorn.rb"
  bundle node[:soupstraw][:bundle_binary]
  environment node.chef_environment
  user deploy_user
end

service 'unicorn' do
  action [ :start, :enable ]
end
