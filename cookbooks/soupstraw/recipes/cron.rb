#
# Cookbook Name:: soupstraw
# Recipe:: cron
#
# Copyright (C) 2013 Soupstraw, Inc.
#

cron "take bitcoin stats snapshot" do
  minute "*/10" # every 10 minutes
  command "cd #{node[:soupstraw][:docroot]} && \
           RACK_ENV=#{node.chef_environment} bundle exec rake bitcoin:snapshot"
  only_if { node[:soupstraw] }
  action :create
end
