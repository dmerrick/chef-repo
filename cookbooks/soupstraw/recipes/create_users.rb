#
# Cookbook Name:: soupstraw
# Recipe:: create_users
#
# Copyright (C) 2013 Soupstraw, Inc.
#

# create sysadmin users
include_recipe "users::sysadmins"

# create the deploy user if necessary
users_manage "deploy" do
  group_id 2301
  only_if { node[:soupstraw] && node[:soupstraw][:deploy_user] }
end

# give deploy user ability to manage unicorn
sudo 'unicorn' do
  group     'deploy'
  commands  ['/etc/init.d/unicorn']
  nopasswd  true
  only_if { node[:soupstraw] && node[:soupstraw][:deploy_user] }
end
