
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


