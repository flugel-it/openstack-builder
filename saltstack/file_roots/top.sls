base:
  '*':
    - base
    - nagios-nrpe
    - openstack-nagios
    #- cloudpassage-agent Doesn't work :P

  'G@roles:nagios':
    - match: compound
    - nagios

