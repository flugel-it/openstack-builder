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




# We need it now, because it's required to render some templates using
# the keystone Salt module.
python-keystoneclient:
  pkg.installed

/etc/salt/minion.d/openstack.conf:
  file.managed:
    - source: salt://openstack/files/openstack.minion.conf
    - template: jinja
    - context:
      controller: {{  salt.openstack.get_controller() }}
    - watch:
      - service: salt-minion

