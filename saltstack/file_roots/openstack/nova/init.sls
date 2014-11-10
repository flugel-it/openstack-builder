
openstack-nova-pkgs:
  pkg.installed:
    - pkgs:
      - mysql-client
      - nova-api
      - nova-cert
      - nova-conductor
      - nova-consoleauth
      - nova-novncproxy
      - nova-scheduler
      - python-novaclient

/etc/salt/minion.d/nova-minion.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/nova/files/nova.minion.conf
    - watch_in:
      - service: salt-minion

/var/lib/nova/nova.sqlite:
  file.absent

{%if "nova-compute" in grains.get("roles", []) %}
/etc/nova/nova-compute.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/nova/files/nova-compute.conf
    - watch_in:
      - service: nova-api
      - service: nova-cert
      - service: nova-consoleauth
      - service: nova-scheduler
      - service: nova-conductor
      - service: nova-novncproxy
{% endif %}

/etc/nova/nova.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/nova/files/nova.conf
    - watch_in:
      - service: nova-api
      - service: nova-cert
      - service: nova-consoleauth
      - service: nova-scheduler
      - service: nova-conductor
      - service: nova-novncproxy

/root/.nova:
  file.managed:
    - source: salt://openstack/nova/files/dot_nova
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/var/log/nova/:
  file.directory:
    - user: nova
    - group: nova
    - mode: 755

nova_db:
  mysql_database.present:
    - connection_pass: {{ pillar['DATABASE'] }}
    - name: {{ pillar['NOVA_DBNAME'] }}
    - connection_host: localhost
  mysql_user.present:
    - name: {{ pillar['NOVA_DBUSER'] }}
    - password: {{ pillar['NOVA_DBPASS'] }}
    - allow_passwordless: False
    - connection_host: localhost
    - host: "%"
    - connection_pass: {{ pillar['DATABASE'] }}
  mysql_grants.present:
    - grant: all privileges
    - database: nova.*
    - host: "%"
    - user: {{ pillar['NOVA_DBUSER'] }}
    - password: {{ pillar['NOVA_DBPASS'] }}
    - connection_pass: {{ pillar['DATABASE'] }}
    - connection_host: localhost
    - require:
      - mysql_user: {{ pillar['NOVA_DBUSER'] }}

Nova fix-db-access.sh:
  cmd.run:
    - name: /usr/local/bin/fix-db-access.sh {{ pillar['NOVA_DBUSER'] }} {{ pillar['NOVA_DBPASS'] }} {{ pillar['DATABASE'] }} nova
    - user: root
    - unless: test -f /etc/salt/.{{ pillar['NOVA_DBUSER'] }}-access-fixed

nova-initdb:
  cmd.run:
    - name: su -s /bin/sh -c "nova-manage db sync" nova && touch /etc/nova/.already_synced
    - unless: test -f /etc/nova/.already_synced
    - user: root

Nova tenants:
  keystone.tenant_present:
    - names:
      - nova

nova_user:
  keystone.user_present:
    - name: nova
    - password: {{ pillar['NOVA_PASS'] }}
    - email: infradevs@flugel.it
    - roles:
      - service:
        - admin
      - require:
        - keystone: Nova tenants

nova_keystone_service:
  keystone.service_present:
    - name: nova
    - service_type: compute
    - description: Openstack Compute Service

nova_keypoint_endpoint:
  keystone.endpoint_present:
    - name: nova
    - publicurl: http://controller:8774/v2/%\(tenant_id\)s
    - internalurl: http://controller:8774/v2/%\(tenant_id\)s
    - adminurl: http://controller:8774/v2/%\(tenant_id\)s
    - region: regionOne
