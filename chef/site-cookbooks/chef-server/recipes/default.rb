#
# Cookbook Name:: chef-server
# Recipe:: default
#
# Copyright 2014, Akilion
#
# All rights reserved - Do Not Redistribute
#

remote_file "/var/tmp/chef-server.deb" do
  source "https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/"\
    "12.04/x86_64/chef-server_11.1.3-1_amd64.deb"
end

dpkg_package "chef-server" do
  action :install
  source "/var/tmp/chef-server.deb"
end

execute "configure-chef" do
  flag_file = "/.chef-server"
  command "chef-server-ctl reconfigure && touch #{flag_file}"
  not_if { ::File.exists?(flag_file)}
end
