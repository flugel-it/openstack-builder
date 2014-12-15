base:
  '*':
    - base
    - swap
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
    - openstack.controller
    - openstack.keystone
    - openstack.glance
    - openstack.nova
    - openstack.nova.controller
    - openstack.neutron.controller
    #- openstack.horizon
    #- openstack.cinder

  'G@roles:openstack-compute':
    - match: compound
    - openstack
    - openstack.nova
    - openstack.nova.compute

  'G@roles:openstack-network':
    - match: compound
    - openstack
    - openstack.neutron
    - openstack.neutron.network

  'G@roles:ceph-client':
    - match: compound
    - ceph

  'G@roles:ironic':
    - match: compound
    - openstack.ironic
