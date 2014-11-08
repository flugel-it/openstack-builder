
openstack-keystone-pkgs:
  pkg.installed:
    - pkgs:
      - mysql-server
      - {{ pillar["rabbitmq-server_pkg"] }}
      - {{ pillar["keystone_pkg"] }}

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

fix-db-access.sh:
  cmd.run:
    - name: /usr/local/bin/fix-db-access.sh {{ pillar['KEYSTONE_DBUSER' }} pillar['KEYSTONE_DBPASS' }} pillar['DATABASE']' }} keystone
    - onlyif: selinuxenabled


keystone_db:
  mysql_database.present:
    - connection_pass: {{ pillar['DATABASE'] }}
    - name: {{ pillar['KEYSTONE_DBNAME'] }}
  mysql_user.present:
    - name: {{ pillar['KEYSTONE_DBUSER'] }}
    - password: {{ pillar['KEYSTONE_DBPASS'] }}
    - host: "%"
    - allow_passwordless: False
    - connection_user: root
    - connection_host: "%"
    - connection_pass: {{ pillar['DATABASE'] }}
    - connection_charset: utf8
  mysql_grants.present:
    - grant: all privileges
    - database: keystone.*
    - host: "%"
    - user: {{ pillar['KEYSTONE_DBUSER'] }}
    - password: {{ pillar['KEYSTONE_DBPASS'] }}
    - connection_user: root
    - connection_pass: {{ pillar['DATABASE'] }}
    - connection_charset: utf8
    - connection_host: "%"
    - require:
      - mysql_user: {{ pillar['KEYSTONE_DBUSER'] }}


keystone-initdb:
  cmd.run:
    - name: su -s /bin/sh -c "keystone-manage db_sync" keystone && touch /etc/keystone/.already_synced
    - unless: test -f /etc/keystone/.already_synced
    - user: root

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
    - password: {{ pillar['KEYSTONE_ADMIN_PASS'] }}
    - email: infradevs@fluge.it
    - roles:
      - admin:   # tenants
        - admin  # roles
    - require:
      - keystone: Keystone tenants
      - keystone: Keystone roles

keystone service:
  keystone.service_present:
    - name: keystone
    - service_type: identity
    - description: OpenStack Identity Service

keystone endpoint:
  keystone.endpoint_present:
    - name: keystone
    - publicurl: http://controller:5000/v2.0
    - internalurl: http://controller:5000/v2.0
    - adminurl: http://controller:35357/v2.0
    - region: RegionOne
