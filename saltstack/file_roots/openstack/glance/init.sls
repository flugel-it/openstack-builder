
openstack-glance-pkgs:
  pkg.installed:
    - pkgs:
      - {{ pillar["glance_pkg"] }}
      - mysql-client

/var/lib/glance/glance.sqlite:
  file.absent

/etc/salt/minion.d/keystone-minion.conf:
    file.managed:
      - template: jinja
      - source: salt://openstack/keystone/files/keystone.minion.conf
      - watch_in:
        - service: salt-minion

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

glance-service:
  service.running:
    - name: glance
    - enable: true
    - watch:
      - file: /etc/glance/glance-api.conf
      - file: /etc/glance/glance-registry.conf

glance_db:
  mysql_database.present:
    - connection_pass: {{ pillar['DATABASE'] }}
    - name: {{ pillar['GLANCE_DBNAME'] }}
    - connection_host: controller
  mysql_user.present:
    - name: {{ pillar['GLANCE_DBUSER'] }}
    - password: {{ pillar['GLANCE_DBPASS'] }}
    - allow_passwordless: False
    - connection_host: controller
    - host: "%"
    - connection_pass: {{ pillar['DATABASE'] }}
  mysql_grants.present:
    - grant: all privileges
    - database: glance.*
    - host: "%"
    - user: {{ pillar['GLANCE_DBUSER'] }}
    - password: {{ pillar['GLANCE_DBPASS'] }}
    - connection_pass: {{ pillar['DATABASE'] }}
    - connection_host: controller
    - require:
      - mysql_user: {{ pillar['GLANCE_DBUSER'] }}

glance-initdb:
  cmd.run:
    - name: su -s /bin/sh -c "glance-manage db_sync" glance && touch /etc/glance/.already_synced
    - unless: test -f /etc/glance/.already_synced
    - user: root

Glance tenants:
  keystone.tenant_present:
    - names:
      - glance

glance_admin_user:
  keystone.user_present:
    - name: glance
    - password: {{ pillar['GLANCE_PASS'] }}
    - email: infradevs@fluge.it
    - roles:
      - admin:   # tenants
        - admin  # roles
      - require:
        - keystone: Glance tenants

glancene_keystone_service:
  keystone.service_present:
    - name: glance
    - service_type: image
    - description: Openstack Image Service
    - watch_in:
      - service:glance-registry
      - service:glance-api

glance_keypoint_endpoint:
  keystone.endpoint_present:
    - name: glance
    - publicurl: http://{{ grains.fqdn_ip4[0] }}:9292
    - internalurl: http://{{ grains.fqdn_ip4[0] }}:9292
    - adminurl: http://{{ grains.fqdn_ip4[0] }}:9292
    - watch_in:
      - service:glance-registry
      - service:glance-api

