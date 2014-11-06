
openstack-glance-pkgs:
  pkg.installed:
    - pkgs:
      - {{ pillar["glance_pkg"] }}


/var/lib/glance/glance.sqlite:
  file.absent:

/etc/salt/minion.d/glance-minion.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/glance/files/glance.minion.conf
    - watch_in:
      - service: salt-minion

/var/log/glance/:
  file.directory:
    - user: glance
    - group: glance
    - mode: 755

/etc/glance/glance-api.conf:
  file.managed:
    - source: salt://openstack/glance/files/glance-registry.conf
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
  mysql_user.present:
    - name: {{ pillar['GLANCE_DBUSER'] }}
    - password: {{ pillar['GLANCE_DBPASS'] }}
    - allow_passwordless: False
    - connection_host: localhost
    - connection_user: root
    - connection_pass: {{ pillar['DATABASE'] }}
    - connection_charset: utf8
  mysql_grants.present:
    - grant: all privileges
    - database: glance.*
    - user: {{ pillar['GLANCE_DBUSER'] }}
    - password: {{ pillar['GLANCE_DBPASS'] }}
    - connection_host: localhost
    - connection_user: root
    - connection_pass: {{ pillar['DATABASE'] }}
    - connection_charset: utf8
    - require:
      - mysql_user: {{ pillar['GLANCE_DBUSER'] }}

glance-initdb:
  cmd.run:
    - name: su -s /bin/sh -c "glance-manage db_sync" glance && touch /etc/glance/.already_synced
    - unless: test -f /etc/glance/.already_synced
    - user: glance

Keystone tenants:
  keystone.tenant_present:
    - names:
      - glance

Keystone roles:
  keystone.role_present:
    - names:
      - admin
      - Member

glance:
  keystone.user_present:
    - password: {{ pillar['GLANCE_PASS'] }}
    - email: infradevs@fluge.it
    - roles:
      - admin:   # tenants
        - admin  # roles
      - service:
        - admin
        - Member
        #- require:
      #- glance: Keystone tenants
      #- glance: Keystone roles
