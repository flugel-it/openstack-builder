base:
  '*':
    - base
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
    - openstack.keystone
    - rabbitmq
    - mysql

  'G@roles:glance':
    - match: compound
    - openstack.glance
