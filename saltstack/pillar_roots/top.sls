
base:
  '*':
    - base

  'P@roles:openstack.*':
    - match: compound
    - openstack
    - openstack.luisv.passwords
    - openstack.keystone
    - openstack.networking
    - openstack.glance

  'G@os:Ubuntu or G@os:Debian':
    - match: compound
    - ubuntu.pkgs
    - ubuntu.paths

  'P@roles:ceph.*':
    - match: compound
    - ceph

  'G@cluster_name:hosting':
    - match: compound
    - providers
    - providers.hosting

  'G@cluster_name:do_test':
    - match: compound
    - providers
    - providers.hosting


