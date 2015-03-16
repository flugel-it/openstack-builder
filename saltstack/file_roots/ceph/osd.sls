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

#XXX: make this a pillar/grain
/var/spool/osd1:
  file.directory

ceph-osd-prepare:
  cmd.run:
    - name: ceph-disk prepare --cluster {{ pillar["ceph_name"] }} --cluster-uuid {{ pillar["ceph_fsid"] }} /var/spool/osd1
    - creates: /var/spool/osd1/magic

ceph-osd-activate:
  cmd.run:
    - name: ceph-disk activate /var/spool/osd1

