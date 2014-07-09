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

execute "create-admin-user" do
  command "maas-region-admin createsuperuser --username=admin "\
    "--noinput --email=admin@akilion.net && touch /.admin"
  not_if { ::File.exists?("/.admin") }
end

execute "set-admin-passwd" do
  command "maas-region-admin createsuperuser --username=admin "\
    "--noinput --email=admin@akilion.net && touch /.admin"
  not_if { ::File.exists?("/.admin") }
end

