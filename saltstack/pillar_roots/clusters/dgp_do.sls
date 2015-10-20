
networks:
  public: 0.0.0.0/0
  private: 10.131.0.0/16

openstack:
  external_iface: eth0
  controller_public: 172.21.22.12
  cinder:
    driver: null

  horizon:
    ssl_key: null
    ssl_crt: null

  neutron:
    dnsmasq_opts:
      - dhcp-option-force=26,1450

  nova:
    compute: nova-compute-lxd

ceph:
  enabled: false
  public_network: 172.21.22.0/24

