#
# Cookbook Name:: maas-cluster-controller
# Recipe:: default
#
# Copyright 2014, Akilion
#
# All rights reserved - Do Not Redistribute
#

maas_region_controller = "atlas-maas-rc.flugel.it"
rabbit_pass = "lqMwDXwk9vhyOItglyI4"

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

maas_services = [
  "maas-cluster-celery",
  "maas-pserv",
  "maas-txlongpoll",
  "maas-region-celery",
  "maas-dhcp-server"
]

for maas_service in maas_services do
  service maas_service do
    provider Chef::Provider::Service::Upstart
    action [:enable, :start]
    subscribes :restart, "ruby_block[set_maas_region_server]", :delayed
  end
end

conf_files = [
  "maas_cluster.conf",
  "maas_local_settings.py",
  "txlongpoll.yaml"
]

for conf_file in conf_files do
  template "/etc/maas/#{conf_file}" do
    mode "0644"
    source "#{conf_file}.erb"
    variables({
      :maas_region_controller => maas_region_controller,
      :rabbit_pass => rabbit_pass
    })
    for maas_service in maas_services do
      notifies :restart, "service[#{maas_service}]", :delayed
    end
  end
end

