
base:
  '*':
    - data    
    - pkgs
    - openstack
    - openstack.passwords

  'G@os:Ubuntu or G@os:Debian':
    - match: compound
    - ubuntu.pkgs
    - ubuntu.paths

controller:
  'G@role:controller':
    - rabbitmq-server_pkgs
