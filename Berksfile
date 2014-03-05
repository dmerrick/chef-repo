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
cookbook 'datadog', path: './cookbooks/datadog'

#FIXME: hopefully they will fix the issue I was having with this
cookbook 'rbenv', path: './cookbooks/rbenv'

# only for chef-solo
group :solo do
  # the opscode version is bugged
  cookbook 'chef-solo-search', github: 'edelight/chef-solo-search', ref: 'master'
end
