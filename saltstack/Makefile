PWD=$(shell pwd)

all:
	-test -d /etc/salt/master.d/ || mkdir -p /etc/salt/master.d/
	-rm -fR /etc/salt/master.d/*
	sed s%PILLAR_ROOTS%$(PWD)/pillar_roots% \
		master.d/pillar_roots.conf > /etc/salt/master.d/pillar.conf
	sed s%FILE_ROOTS%$(PWD)/file_roots% \
		master.d/file_roots.conf > /etc/salt/master.d/file.conf
	-stop salt-master
	start salt-master

