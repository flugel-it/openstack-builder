#
# Cookbook Name:: akilion-libvirt
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

pkgs = [
  "libvirt-bin",
  "virtinst"
]

for pkg in pkgs do
  package pkg
end
