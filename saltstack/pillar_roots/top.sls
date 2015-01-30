
base:
  '*':
    - base

  'P@roles:openstack.*':
    - match: compound
    - openstack
    - openstack.passwords
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
    - clusters
    - clusters.hosting
    - clusters.hosting-password

  'G@cluster_name:globant':
    - match: compound
    - clusters
    - clusters.globant
    - clusters.globant-password

  'G@cluster_name:peak':
    - match: compound
    - providers
    - providers.peak
    - passwords.peak
    - configs.peak


