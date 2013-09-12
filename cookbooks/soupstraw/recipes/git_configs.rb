#
# Cookbook Name:: soupstraw
# Recipe:: git_configs
#
# Copyright (C) 2013 Soupstraw, Inc.
#

%w{ dmerrick mcclurem }.each do |username|

  # check out the git repo
  git "/home/#{username}/configs" do
    repository "https://github.com/#{username}/configs.git"
    reference "master"
  end

  # give the user ownership of everything
  directory "/home/#{username}/configs" do
    owner username
    group username
    recursive true
  end

  # remove the existing config files (if they exist)
  %w{ .bashrc .bash_logout .profile }.each do |filename|
    file "/home/#{username}/#{filename}" do
      action :delete
      not_if { ::File.symlink? name }
    end
  end

  # run setup.sh
  bash "run setup script for #{username}" do
    user username
    cwd "/home/#{username}"
    code "yes 'n' | HOME='/home/#{username}' /home/#{username}/configs/setup.sh"
    not_if { ::File.symlink? "/home/#{username}/.bashrc" }
  end

end


# dana uses a custom bash prompt
directory "/home/dmerrick/other_projects"

git "/home/dmerrick/other_projects/git-prompt" do
  repository "https://github.com/dmerrick/git-prompt.git"
  reference "master"
end

directory "/home/dmerrick/other_projects/git-prompt" do
  owner "dmerrick"
  group "dmerrick"
  recursive true
end

# add pathogen too
directory "/home/dmerrick/.vim/autoload" do
  recursive true
end

remote_file "/home/dmerrick/.vim/autoload/pathogen.vim" do
  source "https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim"
  mode 00755
  action :create_if_missing
end
