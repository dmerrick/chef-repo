#
# Cookbook Name:: soupstraw
# Recipe:: motd
#
# Copyright (C) 2013 Soupstraw, Inc.
#

%w{ 10-help-text 50-landscape-sysinfo 51-cloudguest }.each do |motd_section|
  motd motd_section do
    action :delete
  end
end

motd '52-soupstraw-ascii' do
  cookbook 'soupstraw'
  source "#{name}.sh.erb"
end

motd '53-chef-info' do
  cookbook 'soupstraw'
  source "#{name}.sh.erb"
end
