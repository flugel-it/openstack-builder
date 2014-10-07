base:
  '*':
    - base
    - hostsfile

  'G@roles:openstack':
    - match: compound
    - drbd
    - openstack

  'G@roles:nagios':
    - match: compound
    - nagios

