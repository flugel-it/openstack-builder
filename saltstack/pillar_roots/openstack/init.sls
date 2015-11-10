
openstack:
  release: juno
  region: lxc-lab
  cinder:
    driver: null
  horizon: 
    ssl_key: null

  nova:
    compute: kvm

  glance:
    images:
      - ubuntu-14.04

  neutron:
    dnsmasq_opts: []

