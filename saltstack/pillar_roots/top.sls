
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

  'G@role:controller':
    - match: compound
    - rabbitmq-server
    - openstack.keystone

