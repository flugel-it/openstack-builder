
openstack-keystone:
  pkg.installed:
    - name: {{ pillar.pkgs.keystone }}

/var/lib/keystone/keystone.db:
    file.absent

/etc/salt/minion.d/keystone-minion.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/keystone/files/keystone.minion.conf
    - context:
      controller: {{ salt.openstack.get_controller() }}
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
    - context:
      controller: {{ salt.openstack.get_controller() }}
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
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: root
    - group: root
    - mode: 600

/root/.keystone:
  file.managed:
    - source: salt://openstack/keystone/files/dot_keystone
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: root
    - group: root
    - mode: 600

keystone_db:
  mysql_database.present:
    - name: keystone
  mysql_user.present:
    - name: keystone
    - password: {{ pillar.openstack.keystone_dbpass }}
    - host: '%'
  mysql_grants.present:
    - grant: all privileges
    - database: keystone.*
    - user: keystone
    - host: '%'

keystone-syncdb:
  cmd.run:
    - name: keystone-manage db_sync && touch /etc/keystone/.already_synced
    - unless: test -f /etc/keystone/.already_synced
    - user: keystone

keystone-tenants:
  keystone.tenant_present:
    - names:
      - admin
      - service

keystone-roles:
  keystone.role_present:
    - names:
      - admin
      - _member_

openstack-admin:
  keystone.user_present:
    - name: admin
    - password: {{ pillar.openstack.admin_pass }}
    - email: infradevs@flugel.it
    - roles:
      - admin:
        - admin

keystone-openstack-service:
  keystone.service_present:
    - name: keystone
    - service_type: identity
    - description: OpenStack Identity Service

keystone-endpoint:
  keystone.endpoint_present:
    - name: keystone
    - publicurl: http://{{ salt.openstack.get_controller() }}:5000/v2.0
    - internalurl: http://{{ salt.openstack.get_controller() }}:5000/v2.0
    - adminurl: http://{{ salt.openstack.get_controller() }}:35357/v2.0
    - region: flugelRegion

