
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
      - neutron-lbaas-agent

neutron-plugin-openvswitch-agent:
  service.running:
    - watch:
      - file: /etc/neutron/plugins/ml2/ml2_conf.ini
      - file: /etc/neutron/neutron.conf

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
      - file: /etc/neutron/dnsmasq-custom.conf

neutron-metadata-agent:
  service.running:
    - watch:
      - file: /etc/neutron/metadata_agent.ini
      - file: /etc/neutron/neutron.conf

neutron-lbaas-agent:
  service.running:
    - watch:
      - file: /etc/neutron/lbaas_agent.ini
      - file: /etc/neutron/neutron.conf

/etc/neutron/l3_agent.ini:
  file.managed:
    - source: salt://openstack/neutron/files/l3_agent.ini
    - template: jinja
    - user: neutron
    - group: neutron
    - mode: 640

/etc/neutron/lbaas_agent.ini:
  file.managed:
    - source: salt://openstack/neutron/files/lbaas_agent.ini
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

/etc/neutron/dnsmasq-custom.conf:
  file.managed:
    - source: salt://openstack/neutron/files/dnsmasq-custom.conf
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

# For development purposes only when we tset this on the cloud
{%- if salt.openstack.external_iface() == "dummy0" %}
neutron-modprobe-dummy:
  cmd.run:
    - name: modprobe dummy && echo dummy > /etc/modules
    - unless: grep dummy /etc/modules
{%- endif %}

neutron-create-ext-br:
  cmd.run:
    - name: >
        ovs-vsctl add-br br-ex && 
        ovs-vsctl add-port br-ex {{ salt.openstack.external_iface() }} && 
        touch /etc/neutron/.ovs.configured
    - user: root
    - unless: test -f /etc/neutron/.ovs.configured

