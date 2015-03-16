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




pkgs:
  vim: vim
  mysql_server: mysql-server
  mysql_client: mysql-client
  python_mysqldb: python-mysqldb
  rabbit_server: rabbitmq-server
  python_software_properties: python-software-properties

  glance: glance
  keystone: keystone
  rabbitmq_server: rabbitmq-server
  nova_controller:
    - nova-api
    - nova-cert
    - nova-conductor
    - nova-consoleauth
    - nova-novncproxy
    - nova-scheduler
  nova_compute:
    - nova-compute

