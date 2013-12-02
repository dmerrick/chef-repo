#
# Cookbook Name:: soupstraw
# Recipe:: motd
#
# Copyright (C) 2013 Soupstraw, Inc.
#

#TODO: symlink /var/run/motd.dynamic to /etc/motd here?

# delete these default motd scripts
default_ubuntu_sections = %w{
  00-header
  10-help-text
  50-landscape-sysinfo
  51-cloudguest
}

default_ubuntu_sections.each do |motd_section|
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
