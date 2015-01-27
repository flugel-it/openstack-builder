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
