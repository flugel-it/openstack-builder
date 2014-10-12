base:
  '*':
    - base
    #- hostsfile
    - openstack

  'G@roles:openstack':
    - match: compound
    - drbd
    - openstack

  'G@roles:nagios':
    - match: compound
    - nagios

  'G@roles:controller':
    - rabbitmq
    - match: compound
    - mysql

