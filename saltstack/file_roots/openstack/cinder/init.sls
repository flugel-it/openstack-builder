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




openstack-cinder-pkgs:
  pkg.installed:
    - pkgs:
      - python-cinderclient
      - cinder-common

{%- for dir in [ "/etc/cinder", "/var/log/cinder" ] %}

{{ dir }}:
  file.directory:
    - mode: 755
    - user: cinder
    - group: cinder

{%- endfor %}

/etc/cinder/cinder.conf:
  file.managed:
    - source: salt://openstack/cinder/files/cinder.conf
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
      private_ip: {{ salt.openstack.get_private_ip() }}
    - user: cinder
    - group: cinder
    - mode: 640

