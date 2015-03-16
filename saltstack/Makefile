    This file is part of Openstack-Builder.

    Openstack-Builder is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Openstack-Builder is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Openstack-Builder.  If not, see <http://www.gnu.org/licenses/>.

    Copyright flugel.it LLC
    Authors: Luis Vinay <luis@flugel.it>
             Diego Woitasen <diego@flugel.it>



PWD=$(shell pwd)

all: /usr/bin/salt-master
	-test -d /etc/salt/master.d/ || mkdir -p /etc/salt/master.d/
	-rm -fR /etc/salt/master.d/*
	sed s%PILLAR_ROOTS%$(PWD)/pillar_roots% \
		master.d/pillar_roots.conf > /etc/salt/master.d/pillar.conf
	sed s%FILE_ROOTS%$(PWD)/file_roots% \
		master.d/file_roots.conf > /etc/salt/master.d/file.conf
	ln -sf $(PWD)/salt-cloud/cloud.profiles /etc/salt/cloud.profiles
	ln -sf $(PWD)/salt-cloud/cloud.providers /etc/salt/cloud.providers
	-service salt-master stop
	-service salt-minion stop
	service salt-master start
	service salt-minion start

/usr/bin/salt-master:
	wget -O /tmp/install_salt.sh https://bootstrap.saltstack.com
	sh /tmp/install_salt.sh -A localhost -M git v2014.7.0
