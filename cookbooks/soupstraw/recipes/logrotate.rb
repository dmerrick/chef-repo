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
  options   ['missingok', 'notifempty', 'compress', 'dateext', 'delaycompress']
  frequency 'weekly'
  rotate    52
  su        'deploy'
  postrotate 'pid=/data/soupstraw/shared/tmp/pids/unicorn.pid
              test -s $pid && kill -USR1 "$(cat $pid)"'
  sharedscripts true
  only_if { node[:soupstraw] }
end
