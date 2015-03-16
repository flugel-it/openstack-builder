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




neutron-plugin-ml2:
  pkg.installed
  
python-neutronclient:
  pkg.installed

/var/log/neutron/:
  file.directory:
    - user: neutron
    - group: neutron
    - mode: 755

/etc/neutron/:
  file.directory:
    - user: neutron
    - group: neutron
    - mode: 755

/etc/neutron/neutron.conf:
  file.managed:
    - source: salt://openstack/neutron/files/neutron.conf
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
      tenant_id: {{ salt.keystone.tenant_get(name="service").service.id }}
    - user: neutron
    - group: neutron
    - mode: 640

/etc/neutron/plugins/ml2/ml2_conf.ini:
  file.managed:
    - source: salt://openstack/neutron/files/ml2_conf.ini
    - template: jinja
    - context:
      local_ip: {{ salt.openstack.get_private_ip() }}
    - user: neutron
    - group: neutron
    - mode: 640

