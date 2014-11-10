base:
  '*':
    - base
    - swap
    - hostsfile
    - openstack
    - salt-minion

  'G@roles:openstack':
    - match: compound
    - openstack

  'G@roles:nagios':
    - match: compound
    - nagios

  'G@roles:controller':
    - match: compound
    - rabbitmq
    - mysql
    - openstack
    - openstack.keystone

  'G@roles:glance':
    - match: compound
    - openstack.glance

  'G@roles:nova':
    - match: compound
    - openstack.nova

  'G@roles:nova-compute':
    - match: compound
    - openstack.nova-compute
