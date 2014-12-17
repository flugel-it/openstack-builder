
openstack-cinder-pkgs:
  pkg.installed:
    - pkgs:
      - cinder-api
      - cinder-scheduler
      - cinder-volume
      - python-cinderclient
      - mysql-client

/var/lib/cinder/cinder.sqlite:
  file.absent

/root/.cinder:
  file.managed:
    - source: salt://openstack/cinder/files/dot_cinder
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/var/log/cinder/:
  file.directory:
    - user: cinder
    - group: cinder
    - mode: 755

cinder_db:
  mysql_database.present:
    - name: {{ pillar['CINDER_DBNAME'] }}

cinder-fix-db-access:
  cmd.run:
    - name: /usr/local/bin/fix-db-access.sh {{ pillar['CINDER_DBUSER'] }} {{ pillar['CINDER_DBPASS'] }} {{ pillar['DATABASE'] }} cinder
    - user: root
    - unless: test -f /etc/salt/.{{ pillar['CINDER_DBUSER'] }}-access-fixed

cinder-tenants:
  keystone.tenant_present:
    - names:
      - cinder

cinder_user:
  keystone.user_present:
    - name: cinder
    - password: {{ pillar['CINDER_PASS'] }}
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
    - publicurl: http://controller:8776/v1/%(tenant_id)s
    - internalurl: http://controller:8776/v1/%(tenant_id)s
    - adminurl: http://controller:8776/v1/%(tenant_id)s

cinder-keystone-endpoint-v2:
  keystone.endpoint_present:
    - name: cinderv2
    - publicurl: http://controller:8776/v2/%(tenant_id)s
    - internalurl: http://controller:8776/v2/%(tenant_id)s
    - adminurl: http://controller:8776/v2/%(tenant_id)s

/etc/cinder/cinder.conf:
  file.managed:
    - source: salt://openstack/cinder/files/cinder.conf
    - template: jinja
    - mode: 644

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

