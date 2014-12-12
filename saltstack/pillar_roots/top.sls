
base:
  '*':
    - base
    - data    
    - pkgs
    - ceph

  'P@roles:openstack.*':
    - openstack.passwords
    - openstack.keystone
    - openstack.networking

  'G@os:Ubuntu or G@os:Debian':
    - match: compound
    - ubuntu.pkgs
    - ubuntu.paths

  'G@role:controller':
    - match: compound
    - rabbitmq-server
    - openstack.keystone

