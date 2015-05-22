#!/bin/bash

setup_hostname(){

	CURRHOSTNAME=`cat /etc/hostname | awk -F'.' '{print $1}'`
	MAC=$(ip l | grep link.ether | head -1 | awk '{print $2}' | awk -F\: '{print $4$5$6}')

	if ! grep ${MAC} /etc/hostname; then

		NEWHOSTNAME=${CURRHOSTNAME}-$MAC
		echo ${NEWHOSTNAME} > /etc/hostname
		hostname $NEWHOSTNAME

	fi

}

install_salt(){

	test -d /etc/salt && return

	wget -O install_salt.sh https://bootstrap.saltstack.com &&
	sh install_salt.sh -i $(cat /etc/hostname) \
		-A cloud-master.flugel.it git v2014.7.5 &&
	return 0

	return 1

}

setup_hostname &&
install_salt &&
exit 0

exit 1

