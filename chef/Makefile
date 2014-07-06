IP:=$(shell ip r sh scope link | cut -f9 -d" ")
HOSTNAME:=$(shell hostname)

osdeps:
	apt-get install ruby ruby-dev -y
	gem install bundle
	bundle install

cookbooks:
	librarian-chef install --path cookbooks

fixhosts:
	echo 127.0.0.1 localhost.localdomain localhost > /etc/hosts
	echo $(IP) $(HOSTNAME).akilion.com $(HOSTNAME) >> /etc/hosts

deps: osdeps cookbooks

install-server: deps
	chef-client -z -r 'role[chef-server]' -c .chef/client.rb
