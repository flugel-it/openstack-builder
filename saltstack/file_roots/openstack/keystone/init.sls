
openstack-keystone-pkgs:
  pkg.installed:
    - pkgs:
      - mysql-server
      - {{ pillar["rabbitmq-server_pkg"] }}
      - {{ pillar["keystone_pkg"] }}
  user.present:
    - name: luis
    - uid: 1000 

/etc/salt/minion.d/keystone-minion.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/keystone/files/keystone.minion.conf
    - watch_in:
      - service: salt-minion

/var/log/keystone/:
  file.directory:
    - user: keystone
    - group: keystone
    - mode: 755

/etc/keystone/keystone.conf:
  file.managed:
    - source: salt://openstack/keystone/files/keystone.conf
    - template: jinja
    - user: keystone
    - group: keystone
    - mode: 640

keystone-service:
  service.running:
    - name: keystone
    - enable: true
    - watch:
      - file: /etc/keystone/keystone.conf

/root/.keystone_supercredentials:
  file.managed:
    - source: salt://openstack/keystone/files/dot_keystone_supercredentials
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/root/.keystone:
  file.managed:
    - source: salt://openstack/keystone/files/dot_keystone
    - template: jinja
    - user: root
    - group: root
    - mode: 600

keystone_db:
  mysql_database.present:
    - connection_pass: {{ pillar['DATABASE'] }}
    - name: {{ pillar['KEYSTONE_DBNAME'] }}
  mysql_user.present:
    - name: {{ pillar['KEYSTONE_DBUSER'] }}
    - password: {{ pillar['KEYSTONE_DBPASS'] }}
    - allow_passwordless: False
    - connection_host: localhost
    - connection_user: root
    - connection_pass: {{ pillar['DATABASE'] }}
    - connection_charset: utf8
  mysql_grants.present:
    - grant: all privileges
    - database: keystone.*
    - user: {{ pillar['KEYSTONE_DBUSER'] }}
    - password: {{ pillar['KEYSTONE_DBPASS'] }}
    - connection_host: localhost
    - connection_user: root
    - connection_pass: {{ pillar['DATABASE'] }}
    - connection_charset: utf8
    - require:
      - mysql_user: {{ pillar['KEYSTONE_DBUSER'] }}


keystone-initdb:
  cmd.run:
    - name: /usr/bin/keystone-manage db_sync && touch /etc/keystone/.already_synced
    - unless: test -f /etc/keystone/.already_synced
    - user: keystone

Keystone tenants:
  keystone.tenant_present:
    - names:
      - admin
      - democ
      - service

Keystone roles:
  keystone.role_present:
    - names:
      - admin
      - Member

admin:
  keystone.user_present:
    - password: R00T_4CC3SS
    - email: admin@domain.com
    - roles:
      - admin:   # tenants
        - admin  # roles
      - service:
        - admin
        - Member
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles
