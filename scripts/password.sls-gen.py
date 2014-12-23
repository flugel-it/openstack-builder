#!/usr/bin/python

#
# This is a simple script to generate pretty strong passwords to be used
# in a Openstack implementation.
#
# Luis Vinay - luis@flugel.it
#

import os,binascii

# ToDo: if key.__contains__('USER'): pass

passDescDict = { 'database': 'Root password for the database',
'database_user': 'root',
'keystone_dbpass': 'Database password of Identity service',
'keystone_dbuser': 'keystone',
'demo_pass': 'Password for user demo',
'keystone_admin_pass': 'Password for user Keystone admin',
'admin_pass': ':Password for user admin',
'glance_dbuser': 'glance',
'glance_dbpass': 'Database password for Image Service',
'glance_pass': 'Password for Image Service user glance',
'nova_dbuser': 'nova',
'nova_dbpass': 'Database password for Compute service',
'nova_pass': 'Password for Compute service user nova',
'dash_dbpass': 'Database password for the dashboard',
'cinder_dbpass': 'Database password for the Block Storage service',
'cinder_dbuser': 'Database user for the Block Storage service',
'cinder_pass': 'Password for Block Storage service user cinder',
'neutron_dbuser': 'neutron',
'neutron_dbpass': 'Database password for the Networking service',
'neutron_pass':'Password for Networking service user neutron',
'heat_dbuser': 'heat',
'heat_dbpass': 'Database password for the Orchestration service',
'heat_pass': 'Password for Orchestration service user heat',
'ceilometer_dbpass': 'Database password for the Telemetry service',
'ceilometer_pass': 'Password for Telemetry service user ceilometer',
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
'ironic_dbuser': 'ironic',
'proxy_secret': 'Proxy Secret' }

newPassDicts = { }

# db_root_pass: 08637e971b61355cbe75
# openstack:
#   ironic_dbpass: 


for key in passDescDict.keys():
   newPassDicts[key] = binascii.b2a_hex(os.urandom(10))

print ("db_root_pass: %s\n\nopenstack:" % (newPassDicts['database']))

for key in sorted(newPassDicts.keys()):
    if not key.__contains__('USER'):
        print("  %s: %s" % (key, newPassDicts[key]))
    else:
        print("  %s: %s" % (key, passDescDict[key]))
