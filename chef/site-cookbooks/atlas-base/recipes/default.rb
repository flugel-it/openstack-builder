#
# Cookbook Name:: atlas-base
# Recipe:: default
#
# Copyright 2014, Akilion
#
# All rights reserved - Do Not Redistribute
#

base_pkgs = [
  "ssh",
  "screen",
  "tcpdump",
  "less",
  "vim",
  "nano"
]

for pkg in base_pkgs do
  package pkg do
    action :install
  end
end

