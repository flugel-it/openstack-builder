
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

neutron-compute-plugin-openvswitch-agent-service:
  service.running:
    - name: neutron-plugin-openvswitch-agent
    - watch:
      - file: /etc/neutron/neutron.conf
