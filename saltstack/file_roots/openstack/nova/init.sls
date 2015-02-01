
python-novaclient:
  pkg.installed

nova-common:
  pkg.installed

/var/lib/nova/nova.db:
  file.absent

/etc/nova:
  file.directory:

    - user: nova
    - group: nova
    - mode: 750

/var/log/nova/:
  file.directory:
    - user: nova
    - group: nova
    - mode: 755

/etc/nova/nova.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/nova/files/nova.conf
    - context:
      controller: {{ salt.openstack.get_controller() }}
      public_ip: {{ salt.openstack.get_public_ip() }}
      private_ip: {{ salt.openstack.get_private_ip() }}

# NO ESTOY MUY SEGURO DE ESTA LINEA
{%- if pillar.get('ceilometer') and "openstack-compute" in grains.get("roles", []) %}
ceilometer-agent-compute:
  pkg.installed

# USO EL LA MISMA CONF FILE, QUE SE DA CUENTA SI ES UN COMPUTE
# Y COMENTA LA CONNECCION A LA DB
ceilometer.conf:
  file.managed:
    - source: salt://openstack/ceilometer/files/ceilometer.conf
    - template: jinja
    - mode: 750
    - watch_in:
      - service: ceilometer-agent-central
{%- endif %}
