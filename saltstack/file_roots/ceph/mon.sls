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



{%- import 'ceph/settings.sls' as ceph %}

{%- set mon_map = "/etc/ceph/monmap" %}
{%- set map_create_cmd = [ "monmaptool --create --clobber --fsid " + pillar["ceph_fsid"] ]%}
{%- for ceph_mon_hostname, ceph_mon_ip in ceph.ceph_mons.items() %}
{%- do map_create_cmd.append("--add " + ceph_mon_hostname + " " + ceph_mon_ip|first + ":6789") %}
{%- endfor %}
{%- do map_create_cmd.append(mon_map) %}

ceph-map-create:
  cmd.run:
    - name: {{ map_create_cmd|join(" ") }}
    - creates: /etc/ceph/monmap

{% set mon_dir = "/var/lib/ceph/mon/" + pillar["ceph_name"] + "-" + grains["id"] %}
ceph-dir-create:
  file.directory:
    - name: {{ mon_dir }}

ceph-mon-init:
  cmd.run:
    - name: ceph-mon --mkfs -i {{ grains["id"] }} --monmap {{ mon_map }} --keyring {{ ceph.mon_keyring }}
    - creates: {{ mon_dir }}/keyring
    - require:
      - cmd: ceph-map-create
      - file: ceph-mon-keyring

{{ mon_dir }}/done:
  file.touch:
    - require:
      - cmd: ceph-mon-init
    - watch_in:
      - service: ceph-all

{{ mon_dir }}/upstart:
  file.touch:
    - require:
      - cmd: ceph-mon-init
    - watch_in:
      - service: ceph-all

