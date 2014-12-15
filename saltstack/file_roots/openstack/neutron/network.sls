
net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

net.ipv4.conf.all.rp_filter:
  sysctl.present:
    - value: 0

net.ipv4.conf.default.rp_filter:
  sysctl.present:
    - value: 0

neutron-network-pkgs:
  pkg.installed:
    - pkgs:
      - neutron-plugin-ml2
      - neutron-plugin-openvswitch-agent
      - neutron-l3-agent
      - neutron-dhcp-agent

neutron-plugin-openvswitch-agent:
  service.running

neutron-l3-agent:
  service.running:
    - watch:
      - file: /etc/neutron/l3_agent.ini
      - file: /etc/neutron/neutron.conf

neutron-dhcp-agent:
  service.running:
    - watch:
      - file: /etc/neutron/dhcp_agent.ini
      - file: /etc/neutron/neutron.conf

neutron-metadata-agent:
  service.running:
    - watch:
      - file: /etc/neutron/metadata_agent.ini
      - file: /etc/neutron/neutron.conf

/etc/neutron/l3_agent.ini:
  file.managed:
    - source: salt://openstack/neutron/files/l3_agent.ini
    - template: jinja
    - user: neutron
    - group: neutron
    - mode: 640

/etc/neutron/dhcp_agent.ini:
  file.managed:
    - source: salt://openstack/neutron/files/dhcp_agent.ini
    - template: jinja
    - user: neutron
    - group: neutron
    - mode: 640

/etc/neutron/metadata_agent.ini:
  file.managed:
    - source: salt://openstack/neutron/files/metadata_agent.ini
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
      controller_ip: {{ salt.openstack.get_controller_ip() }}
    - user: neutron
    - group: neutron
    - mode: 640

neutron-create-ext-br:
  cmd.run:
    - name: >
        ovs-vsctl add-br br-ex && 
        ovs-vsctl add-port br-ex {{ pillar.openstack.external_iface }} && 
        touch /etc/neutron/.ovs.configured
    - user: root
    - unless: /etc/neutron/.ovs.configured

