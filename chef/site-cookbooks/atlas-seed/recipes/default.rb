#
# Cookbook Name:: atlas-seed
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

pkgs = [
  "lighttpd",
  "dnsmasq"
]

for pkg in pkgs do
  package pkg
end

mac = node[:macaddress].split(':')
client_id = mac[4] + mac[5]
octeto2 = mac[4].hex
octeto3 = mac[5].hex
subnet = "10.#{octeto2}.#{octeto3}"

file "/var/www/client-id.txt" do
  content client_id
end

execute "eth1-up" do
  command "ifdown eth1; ifup eth1"
  action :nothing
end

template "/etc/network/interfaces" do
  source "interfaces.erb"
  variables :subnet => subnet
  notifies :run, "execute[eth1-up]", :immediately
end

directory "/var/lib/dnsmasq"

file "/etc/init/dnsmasq.conf" do
  action :delete
  notifies :restart, "service[dnsmasq]", :delayed
end

template "/etc/dnsmasq.d/atlas.conf" do
  source "dnsmasq-atlas.conf.erb"
  variables :subnet => subnet
  notifies :restart, "service[dnsmasq]", :delayed
end

service "dnsmasq" do
  action [ :enable, :start ]
end

