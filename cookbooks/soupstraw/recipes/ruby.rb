#
# Cookbook Name:: soupstraw
# Recipe:: ruby
#
# Copyright (C) 2013 Soupstraw, Inc.
#

include_recipe "rbenv"
include_recipe "rbenv::ruby_build"
include_recipe "rbenv::ohai_plugin"

rbenv_ruby node[:soupstraw][:ruby_version] do
  global true
end

rbenv_gem "bundler" do
  ruby_version node[:soupstraw][:ruby_version]
end
