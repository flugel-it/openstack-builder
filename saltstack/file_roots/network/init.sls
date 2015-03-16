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

