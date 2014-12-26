base:
  '*':
    - base
    - hostsfile
    - salt-minion

  'G@roles:nagios':
    - match: compound
    - nagios

  'G@roles:openstack-controller':
    - match: compound
    - mysql
    - rabbitmq
    - openstack
    - openstack.minion
    - openstack.controller
    - openstack.keystone
    - openstack.glance
    - openstack.nova
    - openstack.nova.controller
    - openstack.neutron
    - openstack.neutron.controller
    - openstack.horizon
    - openstack.cinder
    - openstack.cinder.controller
    - openstack.heat

  'G@roles:openstack-compute':
    - match: compound
    - openstack
    - openstack.minion
    - openstack.nova
    - openstack.nova.compute
    - openstack.neutron
    - openstack.neutron.compute

  'G@roles:openstack-network':
    - match: compound
    - openstack
    - openstack.minion
    - openstack.neutron
    - openstack.neutron.network

  'G@roles:openstack-volume':
    - match: compound
    - openstack
    - openstack.minion
    - openstack.cinder
    - openstack.cinder.volume

  'G@roles:ceph-client':
    - match: compound
    - ceph

  'G@roles:ironic':
    - match: compound
    - openstack.ironic

  'G@roles:sahara':
    - match: compound
    - openstack.sahara

