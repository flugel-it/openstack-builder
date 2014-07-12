#
# Cookbook Name:: maas-cluster-controller
# Recipe:: default
#
# Copyright 2014, Akilion
#
# All rights reserved - Do Not Redistribute
#

pkgs = [
  "python-seamicroclient",
  "python-pexpect",
  "maas-cluster-controller"
]

for pkg in pkgs do
  package pkg do
    action :install
  end
end

