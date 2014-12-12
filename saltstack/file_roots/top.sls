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
    #- openstack.horizon
    #- openstack.cinder

  'G@roles:openstack-compute':
    - match: compound
    - openstack
    - openstack.nova.compute

  'G@roles:ceph-client':
    - match: compound
    - ceph

  'G@roles:ironic':
    - match: compound
    - openstack.ironic
