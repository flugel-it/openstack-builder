
openstack-keystone-pkgs:
  pkg.installed:
    - pkgs:
      - mysql-server
      - {{ pillar["rabbitmq-server_pkg"] }}
      - {{ pillar["keystone_pkg"] }}
  user.present:
    - name: luis
    - uid: 1000 

/etc/keystone/keystone.conf:
  file.managed:
    - source: salt://openstack/keystone/files/keystone.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 640

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

/usr/bin/keystone-manage db_sync:
  cmd.run:
    - creates: /etc/keystone/.already_synced
    - unless: test -f /etc/keystone/.already_synced

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
