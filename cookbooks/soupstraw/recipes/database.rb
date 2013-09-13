#
# Cookbook Name:: soupstraw
# Recipe:: database
#
# Copyright (C) 2013 Soupstraw, Inc.
#

# install postgres
include_recipe "postgresql::server"

# ensure it starts at boot
#FIXME: not currently working(?)
service 'postgresql' do
  action :enable
end
