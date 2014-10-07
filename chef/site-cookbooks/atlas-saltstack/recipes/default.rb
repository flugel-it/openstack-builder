#
# Cookbook Name:: atlas-saltstack
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

saltmaster = "atlas-control.flugel.it"

cookbook_file "/usr/local/bin/install-salt.sh" do
  source "install-salt.sh"
  mode 00755
end

execute "install-salt" do
  command "/usr/local/bin/install-salt.sh -M -A #{saltmaster}"
  not_if {File.exists?("/usr/bin/salt-minion")}
end

