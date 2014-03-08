#
# Cookbook Name:: soupstraw
# Recipe:: datadog
#
# Copyright (C) 2014 Soupstraw, Inc.
#

# pull in creds from the data bag
datadog_config = data_bag_item('sensitive_configs', 'datadog')

# set required datadog attributes
node.default['datadog']['api_key'] = datadog_config['api_key']
node.default['datadog']['application_key'] = datadog_config['application_key']

# install datadog client tools
include_recipe 'datadog::dd-agent'
include_recipe 'datadog::dd-handler'
include_recipe 'datadog::network'

# set up postgres integration
node.default['datadog']['postgres'] = datadog_config['postgres']
include_recipe 'datadog::postgres'

# set up nginx integration
node.default['datadog']['nginx'] = datadog_config['nginx']
include_recipe 'datadog::nginx'

# install python API for the dogwrap command
include_recipe 'python::pip'
python_pip 'dogapi'
