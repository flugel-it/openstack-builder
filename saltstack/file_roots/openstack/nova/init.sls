{%- set use_ceph = False %}
{% if "controller" in grains.get("roles", [])%}
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

nova-api-metadata:
  pkg.removed

nova-api:
  pkg:
    - installed
  service:
    - running
    - enable: True

nova-cert:
  pkg:
    - installed
  service:
    - running
    - enable: True

nova-conductor:
  pkg:
    - installed
  service:
    - running
    - enable: True

nova-consoleauth:
  pkg:
    - installed
  service:
    - running
    - enable: True

nova-novncproxy:
  pkg:
    - installed
  service:
    - running
    - enable: True

nova-scheduler:
  pkg:
    - installed
  service:
    - running
    - enable: True
{% endif %}

/etc/salt/minion.d/nova-minion.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/nova/files/nova.minion.conf
    - watch_in:
      - service: salt-minion

/var/lib/nova/nova.sqlite:
  file.absent

{% if pillar['networking_service'] == 'nova-network' and "nova-compute" in grains.get("roles", [])%}
nova-compute-network_pkgs:
  pkg.installed:
    - pkgs:
      - nova-network
{% endif %}

{% if pillar['networking_service'] == 'nova-network' and not "nova-compute" in grains.get("roles", [])%}
nova-compute-network_pkgs:
  pkg.installed:
   - pkgs:
      - nova-network

nova-network:
  service.running:
    - watch:
      - file: /etc/nova/nova.conf
{% endif %}

{%if not "controller" in grains.get("roles", []) %}
nova-api-metadata:
  pkg:
    - installed
  service:
    - running
    - enable: True
{% endif %}

{%if "nova-compute" in grains.get("roles", []) %}
nova-compute:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/nova/nova.conf
  require:
    - pkgs:
      - sysfsutils

/etc/nova/nova-compute.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/nova/files/nova-compute.conf
    - watch_in:
      - service: nova-compute
{% endif %}

/etc/nova/nova.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/nova/files/nova.conf
{%if "nova" in grains.get("roles", []) and "controller" in grains.get("roles", []) %}
    - watch_in:
      - service: nova-api
      - service: nova-cert
      - service: nova-consoleauth
      - service: nova-scheduler
      - service: nova-conductor
      - service: nova-novncproxy
{% endif %}
{%if "nova-compute" in grains.get("roles", []) %}
    - watch_in:
      - service: nova-compute
{% endif %}

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

{%if "controller" in grains.get("roles", []) %}
nova_db:
  mysql_database.present:
    - connection_pass: {{ pillar['DATABASE'] }}
    - name: {{ pillar['NOVA_DBNAME'] }}
    - connection_host: controller
  mysql_user.present:
    - name: {{ pillar['NOVA_DBUSER'] }}
    - password: {{ pillar['NOVA_DBPASS'] }}
    - allow_passwordless: False
    - connection_host: controller
    - host: "%"
    - connection_pass: {{ pillar['DATABASE'] }}
  mysql_grants.present:
    - grant: all privileges
    - database: nova.*
    - host: "%"
    - user: {{ pillar['NOVA_DBUSER'] }}
    - password: {{ pillar['NOVA_DBPASS'] }}
    - connection_pass: {{ pillar['DATABASE'] }}
    - connection_host: controller
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
    - publicurl: http://controller:8774/v2/%(tenant_id)s
    - internalurl: http://controller:8774/v2/%(tenant_id)s
    - adminurl: http://controller:8774/v2/%(tenant_id)s
    - region: FlugelitRegion
{% endif %}

{%if "nova-compute" in grains.get("roles", []) and use_ceph %}

/var/tmp/libvirt-ceph.xml:
  file.managed:
    - source: salt://openstack/nova/files/libvirt-ceph.xml
    - template: jinja

libvirt-ceph-secret-define:
  cmd.run:
    - name: virsh secret-define --file /var/tmp/libvirt-ceph.xml
    - unless: virsh secret-list | grep ceph

libvirt-ceph-secret-set:
  cmd.run:
    - name: virsh secret-set-value --secret 457eb676-33da-42ec-9a8c-9293d545c337 --base64 $(ceph auth get-key client.cinder)

{%- endif %}

