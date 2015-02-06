
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
    - openstack.ceilometer

  'G@os:Ubuntu or G@os:Debian':
    - match: compound
    - ubuntu.pkgs
    - ubuntu.paths

  'P@roles:ceph.*':
    - match: compound
    - ceph

  'G@cluster_name:hosting':
    - match: compound
<<<<<<< HEAD
    - clusters
    - clusters.hosting
    - clusters.hosting-password

  'G@cluster_name:globant':
    - match: compound
    - clusters
    - clusters.globant
    - clusters.globant-password

  'G@cluster_name:raxlab':
    - match: compound
    - clusters
    - clusters.raxlab
    - clusters.raxlab-password

  'G@cluster_name:peak':
=======
    - providers
    - providers.hosting
    #- passwords.hosting

  'G@cluster_name:cloudxos-peak':
>>>>>>> f53cedf95100bb61a1a05ff574028996e49416fc
    - match: compound
    - providers
    - providers.peak
    - passwords.peak
    - configs.peak

<<<<<<< HEAD
  'G@cluster_name:luis-peak':
    - match: compound
    - providers.luis-peak
    - openstack.passwords
    - configs.luis-peak
=======
>>>>>>> f53cedf95100bb61a1a05ff574028996e49416fc

