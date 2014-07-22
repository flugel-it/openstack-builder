IP:=$(shell ip r sh scope link | cut -f9 -d" ")
HOSTNAME:=$(shell hostname)

OSRELEASE:=$(shell lsb_release -sc)

ifeq ($(OSRELEASE),precise)
RUBYPKG:=ruby1.9.1-full ruby1.9.1-dev
else
RUBYPKG:=ruby ruby-dev
endif

osdeps:
	sudo apt-get update
	dpkg -l |grep ruby | awk '{ print $$2; }' | \
		xargs sudo apt-get remove --purge --yes --force-yes
	sudo apt-get install $(RUBYPKG) -y
	sudo gem install rdoc
	sudo gem install bundle
	sudo bundle install

librarian-update:
	librarian-chef update

librarian-install:
	librarian-chef install --path cookbooks

/usr/bin/chef-client: deps
	wget -O /tmp/install-chef.sh \
		https://www.opscode.com/chef/install.sh
	sudo bash /tmp/install-chef.sh

fixhosts:
	echo 127.0.0.1 localhost.localdomain localhost > /etc/hosts
	echo $(IP) $(HOSTNAME).akilion.com $(HOSTNAME) >> /etc/hosts

deps: osdeps cookbooks

/opt/chef-server/bin/chef-server-ctl: deps install-chef-client
	sudo chef-client -z -r 'role[chef-server]' -c .chef/client.rb

install-chef-server: install-client /opt/chef-server/bin/chef-server-ctl 

install-chef-client: /usr/bin/chef-client

install-maas-region:
	sudo chef-client -z -r 'role[maas-region-controller]' -c .chef/client.rb

install-atlas-hyper:
	sudo chef-client -z -r 'role[atlas-hyper]' -c .chef/client.rb

upload:
	knife upload cookbooks
	knife upload roles
	knife upload nodes
	knife upload environments
	knife upload data_bags

