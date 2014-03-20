#
# Cookbook Name:: soupstraw
# Recipe:: cron
#
# Copyright (C) 2014 Soupstraw, Inc.
#

rake_task = "#{node[:soupstraw][:bundle_binary]} exec rake bitcoin:snapshot:all"
cron_command = "cd #{node[:soupstraw][:docroot]}"
cron_command += " && RACK_ENV=#{node.chef_environment} #{rake_task}"

cron 'take bitcoin stats snapshot' do
  user node[:soupstraw][:deploy_user]
  minute '1-59/2' # every other minute
  command cron_command
  only_if { node[:soupstraw] }
  action :create
end
