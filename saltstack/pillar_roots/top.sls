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




base:
  '*':
    - base

  'P@roles:openstack.*':
    - match: compound
    - openstack
    - openstack.passwords
    - openstack.keystone
    - openstack.networking
    - openstack.glance
    - openstack.ceilometer

  'G@os:Ubuntu or G@os:Debian':
    - match: compound
    - ubuntu.pkgs
    - ubuntu.paths

  'P@roles:ceph.*':
    - match: compound
    - ceph

  'G@cluster_name:hosting':
    - match: compound
    - clusters
    - clusters.hosting
    - clusters.hosting-password

  'G@cluster_name:globant':
    - match: compound
    - clusters
    - clusters.globant
    - clusters.globant-password

  'G@cluster_name:raxlab':
    - match: compound
    - clusters
    - clusters.raxlab
    - clusters.raxlab-password

  'G@cluster_name:dolab':
    - match: compound
    - clusters
    - clusters.dolab
    - clusters.dolab-password

  'G@cluster_name:cloudxos-peak':
    - match: compound
    - clusters
    - clusters.peak
    - clusters.peak-password

