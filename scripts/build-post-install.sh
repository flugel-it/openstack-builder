#!/bin/bash

setup_hostname(){

	CURRHOSTNAME=`cat /etc/hostname | awk -F'.' '{print $1}'`
	MAC=$(ip l | grep link.ether | head -1 | awk '{print $2}' | awk -F\: '{print $4$5$6}')

	if ! grep ${MAC} /etc/hostname; then

		NEWHOSTNAME=${CURRHOSTNAME}-$MAC
		echo ${NEWHOSTNAME} > /etc/hostname

		if [ -f /etc/salt/minion_id ]; then
			echo ${NEWHOSTNAME} > /etc/salt/minion_id
			stop salt-minion
			start salt-minion
		fi

		reboot

	fi

}

setup_hostname &&
wget -O install_salt.sh https://bootstrap.saltstack.com &&
sh install_salt.sh -i $HOSTNAME -A cloud-master.flugel.it git v2014.7.0 &&
exit 0

exit 1

