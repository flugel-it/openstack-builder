#!/usr/bin/python

#
# This is a simple script to generate pretty strong passwords to be used
# in a Openstack implementation.
#
# Luis Vinay - luis@flugel.it
#

import os,binascii

# ToDo: if key.__contains__('USER'): pass

passDescDict = { 'DATABASE': 'Root password for the database',
'DATABASE_USER': 'root',
'KEYSTONE_DBPASS': 'Database password of Identity service',
'KEYSTONE_DBUSER': 'keystone',
'DEMO_PASS': 'Password of user demo',
'KEYSTONE_ADMIN_PASS': 'Password of user Keystone admin',
'ADMIN_PASS': ':Password of user admin',
'GLANCE_DBUSER': 'glance',
'GLANCE_DBPASS': 'Database password for Image Service',
'GLANCE_PASS': 'Password of Image Service user glance',
'NOVA_DBUSER': 'nova',
'NOVA_DBPASS': 'Database password for Compute service',
'NOVA_PASS': 'Password of Compute service user nova',
'DASH_DBPASS': 'Database password for the dashboard',
'CINDER_DBPASS': 'Database password for the Block Storage service',
'CINDER_PASS': 'Password of Block Storage service user cinder',
'NEUTRON_DBUSER': 'neutron',
'NEUTRON_DBPASS': 'Database password for the Networking service',
'NEUTRON_PASS':'Password of Networking service user neutron',
'HEAT_DBUSER': 'heat',
'HEAT_DBPASS': 'Database password for the Orchestration service',
'HEAT_PASS': 'Password of Orchestration service user heat',
'CEILOMETER_DBPASS': 'Database password for the Telemetry service',
'CEILOMETER_PASS': 'Password of Telemetry service user ceilometer',
'TROVE_DBPASS': 'Database password of Database service',
'TROVE_PASS': 'Password of Database Service user trove',
'RABBIT_USER': 'rmqquery',
'RABBIT_PASS': 'guest user',
'CINDER_PASS': 'cinder',
'METADATA_PROXY_SECRET': 'Secret for the Metadata Proxy',
'KEYSTONE_TOKEN': 'Keystone Token',
'PROXY_SECRET': 'Proxy Secret' }

newPassDicts = { }

for key in passDescDict.keys():
   newPassDicts[key] = binascii.b2a_hex(os.urandom(10))

for key in newPassDicts.keys():
  print("%s: %s" % (key, newPassDicts[key]))
   #print("%s		%s	%s" % (key, newPassDicts[key], passDescDict[key]))
