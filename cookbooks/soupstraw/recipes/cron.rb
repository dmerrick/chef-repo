#
# Cookbook Name:: soupstraw
# Recipe:: cron
#
# Copyright (C) 2014 Soupstraw, Inc.
#

rake_task = "#{node[:soupstraw][:bundle_binary]} exec rake bitcoin:snapshot:all"
cron_command = "cd #{node[:soupstraw][:docroot]}"
cron_command += " && RACK_ENV=#{node.chef_environment} #{rake_task}"

# if we're using datadog, send them an event when we run this cron job
if node['datadog']['api_key']
  cron_command = "/usr/local/bin/dogwrap -n cron_btc_snapshot -k #{node['datadog']['api_key']} -m all \
  '#{cron_command} > /dev/null'"
end

cron 'take bitcoin stats snapshot' do
  user node[:soupstraw][:deploy_user]
  minute '1-59/2' # every other minute
  command cron_command
  only_if { node[:soupstraw] }
  action :create
end
