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




neutron-compute-all-rp_filter:
  sysctl.present:
    - name: net.ipv4.conf.all.rp_filter
    - value: 0

neutron-compute-default-rp_filter:
  sysctl.present:
    - name: net.ipv4.conf.default.rp_filter
    - value: 0

neutron-compute-plugin-openvswitch-agent:
  pkg.installed:
    - name: neutron-plugin-openvswitch-agent

neutron-compute-plugin-openvswitch-agent-service:
  service.running:
    - name: neutron-plugin-openvswitch-agent
    - watch:
      - file: /etc/neutron/neutron.conf
