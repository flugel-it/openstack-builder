#
# Cookbook Name:: maas-cluster-controller
# Recipe:: default
#
# Copyright 2014, Akilion
#
# All rights reserved - Do Not Redistribute
#

rc_url = "atlas-maas-region-controller.woitasen.com.ar"

pkgs = [
  "python-seamicroclient",
  "python-pexpect",
  "maas-cluster-controller",
  "maas-dns"
]

for pkg in pkgs do
  package pkg do
    action :install
  end
end

ruby_block "set_maas_region_server" do
  block do
    file = Chef::Util::FileEdit.new("/etc/maas/maas_cluster.conf")
    file.search_file_replace_line("^MAAS_URL=.*",
                                  "MAAS_URL=\"#{rc_url}\"")
    file.write_file
  end
end

