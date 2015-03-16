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




neutron-server:
  pkg.installed
  
/root/.neutron:
  file.managed:
    - source: salt://openstack/neutron/files/dot_neutron
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: root
    - group: root
    - mode: 600

neutron-service:
  service.running:
    - name: neutron-server
    - enable: true
    - watch:
      - file: /etc/neutron/neutron.conf
      - file: /etc/neutron/plugins/ml2/ml2_conf.ini

neutron_db:
  mysql_database.present:
    - name: neutron
  mysql_user.present:
    - name: neutron
    - password: {{ pillar.openstack.neutron_dbpass }}
    - host: "%"
  mysql_grants.present:
    - grant: all privileges
    - database: neutron.*
    - user: neutron
    - host: "%"

neutron-initdb:
  cmd.run:
    - name: >
        neutron-db-manage --config-file /etc/neutron/neutron.conf 
        --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade juno && 
        touch /etc/neutron/.already_synced
    - user: neutron
    - unless: test -f /etc/neutron/.already_synced

neutron-user:
  keystone.user_present:
    - name: neutron
    - password: {{ pillar.openstack.neutron_pass }}
    - email: infradevs@flugel.it
    - roles:
      - service:
        - admin

neutron-keystone-service:
  keystone.service_present:
    - name: neutron
    - service_type: network
    - description: Openstack Network Service
    - watch_in:
      - service: neutron-service

neutron-keystone-endpoint:
  keystone.endpoint_present:
    - name: neutron
    - publicurl: http://{{ salt.openstack.get_controller_public() }}:9696
    - internalurl: http://{{ salt.openstack.get_controller() }}:9696
    - adminurl: http://{{ salt.openstack.get_controller() }}:9696
    - require:
      - keystone: neutron-keystone-service
    - watch_in:
      - service: neutron-service


