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




python-ceilometerclient:
  pkg.installed

pymongo:
  pip.installed

{%- for pkg in pillar.openstack.ceilometer.controller_pkgs %}

{{ pkg }}:
  pkg.installed: []
  service.running:
    - watch:
      - file: /etc/ceilometer/ceilometer.conf
      - keystone: openstack-ceilometer-keystone-service

{%- endfor %}

/etc/ceilometer/ceilometer.conf:
  file.managed:
    - source: salt://openstack/ceilometer/files/ceilometer.conf
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - mode: 750

ceilometer-create-user:
  mongodb_user.present:
    - name: ceilometer
    - passwd: {{ pillar.openstack.ceilometer_dbpass }}
    - database: ceilometer

openstack-ceilometer-user:
  keystone.user_present:
    - name: ceilometer
    - password: {{ pillar.openstack.ceilometer_pass }}
    - email: infradevs@flugel.it
    - roles:
      - service:
        - admin

openstack-ceilometer-keystone-service:
  keystone.service_present:
    - name: ceilometer
    - service_type: metering
    - description: Openstack Telemetry Service

openstack-ceilometer-keypoint-endpoint:
  keystone.endpoint_present:
    - name: ceilometer
    - publicurl: http://{{ salt.openstack.get_controller_public() }}:8777
    - internalurl: http://{{ salt.openstack.get_controller() }}:8777
    - adminurl: http://{{ salt.openstack.get_controller() }}:8777
    - region: {{ pillar.openstack.region }}


