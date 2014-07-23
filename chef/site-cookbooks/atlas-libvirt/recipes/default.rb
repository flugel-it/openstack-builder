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
  "virtinst",
  "ruby-guestfs"
]

require 'guestfs'

for pkg in pkgs do
  package pkg
end

cookbook_file "/usr/local/bin/create-vm.sh" do
  mode 00755
  source "create-vm.sh"
end

cookbook_file "/usr/local/bin/set-vm-hostname.rb" do
  mode 00755
  source "set-vm-hostname.rb"
end

remote_file "/root/ubuntu-trusty-akilion.qcow2" do
  source "http://localhost:8080/ubuntu-trusty-akilion.qcow2"
  action :create_if_missing
end

imgs_dir = "/var/lib/libvirt/images"

for vm in [ "atlas-maas-cc", "atlas-juju" ] do
  disk_file = "#{imgs_dir}/#{vm}.qcow2"
  remote_file disk_file do
    source "file:///root/ubuntu-trusty-akilion.qcow2"
    action :create_if_missing
  end
  execute "setup-hostname-#{vm}" do
    command "/usr/local/bin/set-vm-hostname.rb #{disk_file} #{vm} && touch /.#{vm}"
    not_if { File.exist?("/.#{vm}") }
  end
  execute "setup-#{vm}" do
    command "/usr/local/bin/create-vm.sh"
    not_if {File.exists?("/etc/libvirt/qemu/#{vm}.xml")}
    environment "NAME" => vm 
  end
end

