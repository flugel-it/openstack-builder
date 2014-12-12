
openstack-glance:
  pkg.installed:
    - name: {{ pillar.pkgs.glance }}

/var/lib/glance/glance.db:
  file.absent

/etc/salt/minion.d/glance-minion.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/glance/files/glance.minion.conf
    - watch_in:
      - service: salt-minion

/root/.glance:
  file.managed:
    - source: salt://openstack/glance/files/dot_glance
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/var/log/glance/:
  file.directory:
    - user: glance
    - group: glance
    - mode: 755

/etc/glance/glance-api.conf:
  file.managed:
    - source: salt://openstack/glance/files/glance-api.conf
    - template: jinja
    - user: glance
    - group: glance
    - mode: 640

/etc/glance/glance-registry.conf:
  file.managed:
    - source: salt://openstack/glance/files/glance-registry.conf
    - template: jinja
    - user: glance
    - group: glance
    - mode: 640

glance-api-service:
  service.running:
    - name: glance-api
    - enable: true
    - watch:
      - file: /etc/glance/glance-api.conf

glance-registry-service:
  service.running:
    - name: glance-registry
    - enable: true
    - watch:
      - file: /etc/glance/glance-registry.conf

glance_db:
  mysql_database.present:
    - connection_pass: {{ pillar['DATABASE'] }}
    - name: {{ pillar['GLANCE_DBNAME'] }}
    - connection_host: localhost
  mysql_user.present:
    - name: {{ pillar['GLANCE_DBUSER'] }}
    - password: {{ pillar['GLANCE_DBPASS'] }}
    - allow_passwordless: False
    - connection_host: localhost
    - host: "%"
    - connection_pass: {{ pillar['DATABASE'] }}
  mysql_grants.present:
    - grant: all privileges
    - database: glance.*
    - host: "%"
    - user: {{ pillar['GLANCE_DBUSER'] }}
    - password: {{ pillar['GLANCE_DBPASS'] }}
    - connection_pass: {{ pillar['DATABASE'] }}
    - connection_host: localhost
    - require:
      - mysql_user: {{ pillar['GLANCE_DBUSER'] }}

Glance fix-db-access.sh:
  cmd.run:
    - name: /usr/local/bin/fix-db-access.sh {{ pillar['GLANCE_DBUSER'] }} {{ pillar['GLANCE_DBPASS'] }} {{ pillar['DATABASE'] }} glance
    - user: root
    - unless: test -f /etc/salt/.{{ pillar['GLANCE_DBUSER'] }}-access-fixed

glance-initdb:
  cmd.run:
    - name: su -s /bin/sh -c "glance-manage db_sync" glance && touch /etc/glance/.already_synced
    - unless: test -f /etc/glance/.already_synced
    - user: root

Glance tenants:
  keystone.tenant_present:
    - names:
      - glance

glance_user:
  keystone.user_present:
    - name: glance
    - password: {{ pillar['GLANCE_PASS'] }}
    - email: infradevs@flugel.it
    - roles:
      - service:
        - admin
      - require:
        - keystone: Glance tenants

glance_keystone_service:
  keystone.service_present:
    - name: glance
    - service_type: image
    - description: Openstack Image Service
    - watch_in:
      - service: glance-registry
      - service: glance-api

glance_keypoint_endpoint:
  keystone.endpoint_present:
    - name: glance
    - publicurl: http://controller:9292
    - internalurl: http://controller:9292
    - adminurl: http://controller:9292
    - watch_in:
      - service:glance-registry
      - service:glance-api
