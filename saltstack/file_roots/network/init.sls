
{%- set public_iface = salt.openstack.external_iface() %}
{%- set cluster_name = grains['cluster_name'] %}

networking_pkgs:
  pkg.installed:
    - pkgs:
      - bridge-utils
      - vlan
      - ifenslave

/etc/network/interfaces.new:
  file.managed:
    - source: salt://network/files/{{ cluster_name }}/interfaces
    - template: jinja
    - context:
      public_iface: {{ public_iface }}
      iface_info: {{ salt.openstack.iface_info(public_iface) }}
    - mode: 640

