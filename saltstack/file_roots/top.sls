base:
  '*':
    - base
    - hostsfile

  'G@roles:openstack':
    - match: compound
    #- drbd
    - openstack

  'G@roles:nagios':
    - match: compound
    - nagios

  'G@roles:controller':
    - match: compound
    - openstack
    - openstack.keystone
    - rabbitmq
    - mysql

