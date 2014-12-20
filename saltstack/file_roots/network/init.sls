
{%- set public_iface = salt.openstack.external_iface() %}

bridge-utils:
  pkg.installed

vlan:
  pkg.installed

/etc/network/interfaces:
  file.managed:
    - source: salt://network/files/interfaces
    - template: jinja
    - context:
      public_iface: {{ public_iface }}
      iface_info: {{ salt.openstack.iface_info(public_iface) }}
    - mode: 640

