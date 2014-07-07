#
# Cookbook Name:: maas-region-controller
# Recipe:: default
#
# Copyright 2014, Akilion
#
# All rights reserved - Do Not Redistribute
#

pkgs = [
  "python-seamicroclient",
  "maas-region-controller"
]

for pkg in deps do
  package "python-seamicroclient" do
    action :install
  end
end
