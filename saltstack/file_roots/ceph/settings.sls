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



{%- set mon_keyring = "/etc/ceph/ceph.mon.keyring" %}
{%- set admin_keyring = "/etc/ceph/ceph.client.admin.keyring" %}

{%- set ceph_mon_ips = [] %}
{%- set ceph_mon_hostnames = [] %}
{%- set ceph_mons = salt['mine.get']('roles:ceph-mon', 'network.ip_addrs', expr_form="grain_pcre") %}
{%- for minion, ip_addrs in ceph_mons.items() %}
  {%- do ceph_mon_ips.append(ip_addrs|first + ":6789") %}
  {%- do ceph_mon_hostnames.append(minion) %}
{%- endfor %}

