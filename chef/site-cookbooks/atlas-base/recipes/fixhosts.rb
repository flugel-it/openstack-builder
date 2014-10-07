#
# Cookbook Name:: atlas-base
# Recipe:: default
#
# Copyright 2014, Akilion
#
# All rights reserved - Do Not Redistribute
#

require 'socket'

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

#Fix /etc/hosts
domain = 'flugel.it'
hostname = Socket.gethostname
first_ip = Socket.ip_address_list.detect { |ip| ip.ipv4? and !ip.ipv4_loopback? }
ip = first_ip.getnameinfo[0]

if hostname.include? "."
  raise "dots not allowed in hostnames: #{hostnames}"
end

if not ip
  raise "IP address could not be discovered"
end

file "/etc/hosts" do
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "
127.0.0.1 localhost.localdomain localhost
#{ip} #{hostname}.#{domain} #{hostname}

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
  "
end

