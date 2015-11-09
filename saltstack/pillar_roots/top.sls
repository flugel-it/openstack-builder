
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

  'G@os_family:Debian':
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

  'G@cluster_name:raxlab':
    - match: compound
    - clusters
    - clusters.raxlab
    - clusters.raxlab-password

  'G@cluster_name:dodgp':
    - match: compound
    - clusters
    - clusters.dolab
    - clusters.dolab-password

  'G@cluster_name:dolab':
    - match: compound
    - clusters
    - clusters.dolab
    - clusters.dolab-password

  'G@cluster_name:cloudxos-peak':
    - match: compound
    - clusters
    - clusters.peak
    - clusters.peak-password

  'G@cluster_name:quantum':
    - match: compound
    - clusters
    - clusters.quantum
    - clusters.quantum-password

  'G@cluster_name:mobile-lab':
    - match: compound
    - clusters
    - clusters.mobile-lab
    - clusters.mobile-lab-password

  'G@cluster_name:gcoop':
    - match: compound
    - clusters
    - clusters.gcoop
    - clusters.gcoop-password

