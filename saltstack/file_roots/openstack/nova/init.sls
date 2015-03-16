    This file is part of Openstack-Builder.

    Openstack-Builder is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Openstack-Builder is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Openstack-Builder.  If not, see <http://www.gnu.org/licenses/>.

    Copyright flugel.it LLC
    Authors: Luis Vinay <luis@flugel.it>
             Diego Woitasen <diego@flugel.it>




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
      controller_public: {{ salt.openstack.get_controller_public() }}
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

