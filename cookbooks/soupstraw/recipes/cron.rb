#
# Cookbook Name:: soupstraw
# Recipe:: cron
#
# Copyright (C) 2013 Soupstraw, Inc.
#


rake_task = "#{node[:soupstraw][:bundle_binary]} exec rake bitcoin:snapshot"
cron_command = "cd #{node[:soupstraw][:docroot]} && \
RACK_ENV=#{node.chef_environment} #{rake_task}"

cron "take bitcoin stats snapshot" do
  user node[:soupstraw][:deploy_user]
  minute "*" # every minute
  command cron_command
  only_if { node[:soupstraw] }
  action :create
end
