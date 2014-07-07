IP:=$(shell ip r sh scope link | cut -f9 -d" ")
HOSTNAME:=$(shell hostname)

osdeps:
	sudo apt-get install ruby ruby-dev -y
	sudo gem install bundle
	sudo bundle install

cookbooks:
	librarian-chef install --path cookbooks

/usr/bin/chef-client:
	wget -O /tmp/install-chef.sh \
		https://www.opscode.com/chef/install.sh
	sudo bash /tmp/install-chef.sh

fixhosts:
	echo 127.0.0.1 localhost.localdomain localhost > /etc/hosts
	echo $(IP) $(HOSTNAME).akilion.com $(HOSTNAME) >> /etc/hosts

deps: osdeps cookbooks

/opt/chef-server/bin/chef-server-ctl: deps install-client
	sudo chef-client -z -r 'role[chef-server]' -c .chef/client.rb

install-server: /opt/chef-server/bin/chef-server-ctl

install-client: /usr/bin/chef-client

