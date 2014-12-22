
openstack-cinder-controller-pkgs:
  pkg.installed:
    - pkgs:
      - cinder-api
      - cinder-scheduler

/var/lib/cinder/cinder.sqlite:
  file.absent

/root/.cinder:
  file.managed:
    - source: salt://openstack/cinder/files/dot_cinder
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: root
    - group: root
    - mode: 600

cinder_db:
  mysql_database.present:
    - name: cinder
  mysql_user.present:
    - name: cinder
    - password: {{ pillar.openstack.cinder_dbpass }}
    - host: "%"
  mysql_grants.present:
    - grant: all privileges
    - database: cinder.*
    - user: cinder
    - host: "%"

cinder-initdb:
  cmd.run:
    - name: cinder-manage db sync && touch /etc/cinder/.already_synced
    - unless: test -f /etc/cinder/.already_synced
    - user: cinder
    - require:
      - file: /etc/cinder/cinder.conf

{%- for service in [ "cinder-scheduler", "cinder-api" ] %}

{{ service }}:
  service.running:
    - enable: true
    - require:
      - cmd: cinder-initdb
    - watch:
      - file: /etc/cinder/cinder.conf

{%- endfor %}

cinder_user:
  keystone.user_present:
    - name: cinder
    - password: {{ pillar.openstack.cinder_pass }}
    - email: infradevs@flugel.it
    - roles:
      - service:
        - admin
      - require:
        - keystone: cinder-tenants

cinder-keystone-service:
  keystone.service_present:
    - name: cinder
    - service_type: volume
    - description: Openstack Block Storage Service

cinder-keystone-service-v2:
  keystone.service_present:
    - name: cinderv2
    - service_type: volumev2
    - description: Openstack Block Storage Service V2

cinder-keystone-endpoint:
  keystone.endpoint_present:
    - name: cinder
    - publicurl: http://{{ salt.openstack.get_controller() }}:8776/v1/%(tenant_id)s
    - internalurl: http://{{ salt.openstack.get_controller() }}:8776/v1/%(tenant_id)s
    - adminurl: http://{{ salt.openstack.get_controller() }}:8776/v1/%(tenant_id)s

cinder-keystone-endpoint-v2:
  keystone.endpoint_present:
    - name: cinderv2
    - publicurl: http://{{ salt.openstack.get_controller() }}:8776/v2/%(tenant_id)s
    - internalurl: http://{{ salt.openstack.get_controller() }}:8776/v2/%(tenant_id)s
    - adminurl: http://{{ salt.openstack.get_controller() }}:8776/v2/%(tenant_id)s

