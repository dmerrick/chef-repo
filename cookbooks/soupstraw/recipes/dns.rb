#
# Cookbook Name:: soupstraw
# Recipe:: dns
#
# Copyright (C) 2013 Soupstraw, Inc.
#

# pull in creds from the aws data bag
aws = Chef::DataBagItem.load("aws", "main")

include_recipe "route53"

# workaround for an issue in the route53 cookbook
chef_gem "fog"

route53_record "create a DNS record for #{node.name}" do
  name "#{node.name}.soupstraw.com"

  if node[:ec2]
    value node[:ec2][:public_hostname]
    type "CNAME"
  else
    value node.ipaddress
    type "A"
  end

  zone_id               aws["soupstraw_zone_id"]
  aws_access_key_id     aws["aws_access_key_id"]
  aws_secret_access_key aws["aws_secret_access_key"]

  action :create
end

#TODO: delete the record when the instance goes down
