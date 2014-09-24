base:
  '*':
    - base
    - hostsfile

  'G@roles:openstack':
    - match: compound
    - openstack

  'G@roles:nagios':
    - match: compound
    - nagios

