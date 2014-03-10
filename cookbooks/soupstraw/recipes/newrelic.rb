#
# Cookbook Name:: soupstraw
# Recipe:: newrelic
#
# Copyright (C) 2014 Soupstraw, Inc.
#

# pull in creds from the data bag
newrelic_config = data_bag_item('sensitive_configs', 'newrelic')

# set newrelic license key attribute
node.default['newrelic']['server_monitoring']['license'] = newrelic_config['license']

include_recipe 'newrelic'
