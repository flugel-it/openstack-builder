# -*- mode: ruby -*-
# vi: set ft=ruby :

project = "atlas-seed"

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = project

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 512]
    v.customize ["modifyvm", :id, "--cpus", 1]
  end

  config.vm.box = "ubuntu-14.04"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box"

  config.vm.provision "shell", path: "chef/install-chef.sh"
  
  config.vm.provision "chef_solo" do |chef|
    chef.cookbooks_path = ["chef/site-cookbooks", "chef/cookbooks"]
    chef.add_recipe "atlas-base"
  end

end
