
{%- set public_iface = salt.openstack.external_iface() %}
{%- set last_octet = salt.openstack.get_last_octet() %}
{%- set cluster_name = grains['cluster_name'] %}

networking_pkgs:
  pkg.installed:
    - pkgs:
      - bridge-utils
      - vlan
      - ifenslave

/etc/network/interfaces:
  file.managed:
    - source: salt://network/files/{{ cluster_name }}/interfaces
    - template: jinja
    - context:
      last_octet: {{ last_octet }}
      public_iface: {{ public_iface }}
      iface_info: {{ salt.openstack.iface_info(public_iface) }}
    - mode: 640

