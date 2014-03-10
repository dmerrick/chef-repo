#
# Cookbook Name:: soupstraw
# Recipe:: logrotate
#
# Copyright (C) 2014 Soupstraw, Inc.
#

logrotate_app 'soupstraw' do
  path    %w{ /data/soupstraw/shared/log/unicorn.stdout.log
              /data/soupstraw/shared/log/unicorn.stderr.log
              /data/soupstraw/shared/log/newrelic_agent.log
            }
  options   ['missingok', 'notifempty']
  frequency 'weekly'
  rotate    52
  su        'deploy'
  only_if { node[:soupstraw] }
end

logrotate_app 'chef-client' do
  path      '/var/log/chef/client.log'
  options   ['missingok', 'notifempty']
  frequency 'daily'
  rotate    30
  su        'root'
end
