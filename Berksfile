site :opscode

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

# only for chef-solo
group :solo do
  # the opscode version is bugged
  cookbook 'chef-solo-search', github: 'edelight/chef-solo-search', ref: 'master'
end
