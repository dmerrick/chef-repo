#
# Cookbook Name:: soupstraw
# Recipe:: nginx
#
# Copyright (C) 2013 Soupstraw, Inc.
#

deploy_user = node[:soupstraw][:deploy_user]

# install nginx
include_recipe 'nginx'
include_recipe 'nginx::http_stub_status_module'

#TODO:
# create /etc/nginx/certs
# add .key and .crt files

template "#{node['nginx']['dir']}/sites-available/soupstraw" do
  owner deploy_user
  group deploy_user
  mode 00644
  notifies :reload, 'service[nginx]'
  variables(
    :name => node.name,
    :shared_dir => node[:soupstraw][:shared_dir],
    :docroot => node[:soupstraw][:docroot]
  )
end

# add soupstraw to sites-enabled
nginx_site 'soupstraw'
