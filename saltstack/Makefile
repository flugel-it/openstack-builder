PWD:=$(shell pwd)
MASTERCFG:="/etc/salt/master.d/99-local-roots.conf"

config:
	sed 's%PWD%$(PWD)%' local-roots.conf > $(MASTERCFG)
	restart salt-master
