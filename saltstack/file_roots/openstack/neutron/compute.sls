
neutron-compute-all-rp_filter:
  sysctl.present:
    - name: net.ipv4.conf.all.rp_filter
    - value: 0

neutron-compute-default-rp_filter:
  sysctl.present:
    - name: net.ipv4.conf.default.rp_filter
    - value: 0

neutron-compute-plugin-openvswitch-agent:
  pkg.installed:
    - name: neutron-plugin-openvswitch-agent

