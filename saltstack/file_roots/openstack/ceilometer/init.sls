
ceilometer-pkgs:
  pkg.installed:
    - pkgs:
      - ceilometer-api
      - ceilometer-collector
      - ceilometer-agent-central
      - ceilometer-agent-notification
      - ceilometer-alarm-evaluator
      - ceilometer-alarm-notifier
      - python-ceilometerclient

ceilometer.conf:
  file.managed:
    - source: salt://openstack/ceilometer/files/ceilometer.conf
    - template: jinja
    - mode: 750
    - watch_in:
      - service: ceilometer-agent-central
      - service: ceilometer-agent-notification
      - service: ceilometer-api
      - service: ceilometer-collector
      - service: ceilometer-alarm-evaluator
      - service: ceilometer-alarm-notifier

/usr/local/bin/create-ceilometer-db.sh:
  file.managed:
    - source: salt://openstack/ceilometer/files/create-db.sh
    - mode: 750

openstack-ceilometer-initdb:
  cmd.run:
    - name: salt://openstack/ceilometer/files/create-db.sh touch /etc/ceilometer/.already_synced
    - unless: test -f /etc/ceilometer/.already_synced

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
    - service_type: Metering
    - description: Openstack Telemetry Service

openstack-ceilometer-keypoint-endpoint:
  keystone.endpoint_present:
    - name: ceilometer
    - publicurl: http://{{ salt.openstack.get_controller_public() }}:8777
    - internalurl: http://{{ salt.openstack.get_controller() }}:8777
    - adminurl: http://{{ salt.openstack.get_controller() }}:8777
    - region: {{ pillar.openstack.region }}


