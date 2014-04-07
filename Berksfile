source 'http://api.berkshelf.com'

cookbook 'apt', '>= 2.0.0'
cookbook 'build-essential'
cookbook 'git'
cookbook 'sudo'
cookbook 'users'
cookbook 'vim'
cookbook 'mosh'
cookbook 'tmux'
cookbook 'soupstraw', path: './cookbooks/soupstraw'
cookbook 'hostname'
cookbook 'chef-client'
cookbook 'motd'
cookbook 'nginx'
# using git because I need a fix that's in master but not yet released
# c.p. https://github.com/DataDog/chef-datadog/issues/79
cookbook 'datadog', github: 'DataDog/chef-datadog'
# using git because I need version 0.6.0 and it's not in Berkshelf yet
cookbook 'newrelic', github: 'dmerrick/newrelic'
cookbook 'rbenv'

# only for chef-solo
group :solo do
  # the opscode version is bugged
  cookbook 'chef-solo-search', github: 'edelight/chef-solo-search', ref: 'master'
end
