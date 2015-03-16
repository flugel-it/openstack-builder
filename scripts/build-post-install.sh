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

