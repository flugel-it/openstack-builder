base:
  '*':
    - base
    - swap
    - hostsfile
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
    - openstack.keystone

  'G@roles:glance':
    - match: compound
    - openstack.glance

  'G@roles:nova':
    - match: compound
    - openstack.nova

  'G@roles:horizon':
    - match: compound
    - openstack.horizon
