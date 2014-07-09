IP:=$(shell ip r sh scope link | cut -f9 -d" ")
HOSTNAME:=$(shell hostname)

OSRELEASE:=$(shell lsb_release -sc)

ifeq ($(OSRELEASE),precise)
RUBYGEMS:=rubygems
else
RUBYGEMS:=
endif

osdeps:
	sudo apt-get update
	sudo apt-get install ruby $(RUBYGEMS) ruby-dev -y
	sudo gem install rdoc
	sudo gem install bundle
	sudo bundle install

cookbooks:
	librarian-chef install --path cookbooks

/usr/bin/chef-client: deps
	wget -O /tmp/install-chef.sh \
		https://www.opscode.com/chef/install.sh
	sudo bash /tmp/install-chef.sh

fixhosts:
	echo 127.0.0.1 localhost.localdomain localhost > /etc/hosts
	echo $(IP) $(HOSTNAME).akilion.com $(HOSTNAME) >> /etc/hosts

deps: osdeps cookbooks

/opt/chef-server/bin/chef-server-ctl: deps install-client
	sudo chef-client -z -r 'role[chef-server]' -c .chef/client.rb

install-server: install-client /opt/chef-server/bin/chef-server-ctl 

install-client: /usr/bin/chef-client

install-maas-region:
	sudo chef-client -z -r 'role[maas-region-controller]' -c .chef/client.rb

