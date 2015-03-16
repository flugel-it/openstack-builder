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
    - hostsfile
    - salt-minion
    - swap

  'G@roles:nagios':
    - match: compound
    - nagios

  'G@roles:openstack-controller':
    - match: compound
    - mysql
    - rabbitmq
    - openstack
    - openstack.minion
    - openstack.controller
    - openstack.keystone
    - openstack.glance
    - openstack.nova
    - openstack.nova.controller
    - openstack.neutron
    - openstack.neutron.controller
    - openstack.horizon
    - openstack.cinder
    - openstack.cinder.controller
    - openstack.heat

  'G@roles:openstack-compute':
    - match: compound
    - openstack
    - openstack.minion
    - openstack.nova
    - openstack.nova.compute
    - openstack.nova.ceilometer
    - openstack.neutron
    - openstack.neutron.compute

  'G@roles:openstack-network':
    - match: compound
    - openstack
    - openstack.minion
    - openstack.neutron
    - openstack.neutron.network

  'G@roles:openstack-volume':
    - match: compound
    - openstack
    - openstack.minion
    - openstack.cinder
    - openstack.cinder.volume

  'G@roles:ceph-client':
    - match: compound
    - ceph

  'G@roles:ironic':
    - match: compound
    - openstack.ironic

  'G@roles:sahara':
    - match: compound
    - openstack.sahara

  'G@roles:ceilometer':
    - match: compound
    - mongodb
    - openstack.ceilometer

