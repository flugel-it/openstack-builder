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



#!/usr/bin/python

#
# This is a simple script to generate pretty strong passwords to be used
# in a Openstack implementation.
#
# Luis Vinay - luis@flugel.it
#

import os,binascii
import yaml

passwd_desc = { 
    'mysql.pass': 'Root password for the database'
    }

os_passwd_desc = {
    'keystone_dbpass': 'Database password of Identity service',
    'demo_pass': 'Password for user demo',
    'admin_pass': ':Password for user admin',
    'glance_dbpass': 'Database password for Image Service',
    'glance_pass': 'Password for Image Service user glance',
    'nova_dbpass': 'Database password for Compute service',
    'nova_pass': 'Password for Compute service user nova',
    'dash_dbpass': 'Database password for the dashboard',
    'cinder_dbpass': 'Database password for the Block Storage service',
    'cinder_pass': 'Password for Block Storage service user cinder',
    'neutron_dbpass': 'Database password for the Networking service',
    'neutron_pass':'Password for Networking service user neutron',
    'heat_dbpass': 'Database password for the Orchestration service',
    'heat_pass': 'Password for Orchestration service user heat',
    'ceilometer_dbpass': 'Database password for the Telemetry service',
    'ceilometer_pass': 'Password for Telemetry service user ceilometer',
    'metering_secret': 'Metering Shared Secret',
    'sahara_dbpass': 'Database password of Sahara service',
    'sahara_pass': 'Password for Database Service user sahara',
    'trove_dbpass': 'Database password of Database service',
    'trove_pass': 'Password for Database Service user trove',
    'rabbit_user': 'rmqquery',
    'rabbit_pass': 'guest user',
    'cinder_pass': 'cinder',
    'metadata_proxy_secret': 'Secret for the Metadata Proxy',
    'keystone_token': 'Keystone Token',
    'ironic_dbpass': 'Database password for the Ironic service',
    'ironic_pass': 'Password for Telemetry service user ceilometer',
    'proxy_secret': 'Proxy Secret'
}

new_passwds = {}

for key in passwd_desc:
   new_passwds[key] = binascii.b2a_hex(os.urandom(10))

new_passwds["openstack"] = {}
for key in os_passwd_desc.keys():
    if "user" in key:
        continue

    passwd = binascii.b2a_hex(os.urandom(10))
    if key == "keystone_token":
        new_passwds["keystone.token"] = passwd
    new_passwds["openstack"][key] = passwd

print yaml.dump(new_passwds, default_flow_style=False)

