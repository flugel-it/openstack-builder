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




sysfsutils:
  pkg.installed

{%- for pkg in pillar.pkgs.nova_compute %}

openstack-{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}

{{ pkg }}-service:
  service.running:
    - name: {{ pkg }}
    - watch:
      - file: /etc/nova/nova.conf
      - file: /etc/nova/nova-compute.conf

{%- endfor %}


/etc/nova/nova-compute.conf:
  file.managed:
    - source: salt://openstack/nova/files/nova-compute.conf
    - template: jinja

