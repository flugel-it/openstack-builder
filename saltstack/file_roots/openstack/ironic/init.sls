
{% if "ironic" in grains.get("roles", [])%}
openstack-ironic-pkgs:
  pkg.installed:
    - pkgs:
      - ironic-api
      - ironic-conductor
      - python-ironicclient

btrfs-tools:
  pkg.removed
{% endif %}

/etc/salt/minion.d/ironic-minion.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/ironic/files/ironic.minion.conf
    - watch_in:
      - service: salt-minion

/var/lib/ironic/ironic.sqlite:
  file.absent

/root/.ironic:
  file.managed:
    - source: salt://openstack/ironic/files/dot_ironic
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/var/log/ironic/:
  file.directory:
    - user: ironic
    - group: ironic
    - mode: 755

ironic_db:
  mysql_database.present:
    - connection_pass: {{ pillar['DATABASE'] }}

    - name: {{ pillar['IRONIC_DBNAME'] }}
    - connection_host: controller
  mysql_user.present:
    - name: {{ pillar['IRONIC_DBUSER'] }}
    - password: {{ pillar['IRONIC_DBPASS'] }}
    - allow_passwordless: False
    - connection_host: controller
    - host: "%"
    - connection_pass: {{ pillar['DATABASE'] }}
  mysql_grants.present:
    - grant: all privileges
    - database: ironic.*
    - host: "%"
    - user: {{ pillar['IRONIC_DBUSER'] }}
    - password: {{ pillar['IRONIC_DBPASS'] }}
    - connection_pass: {{ pillar['DATABASE'] }}
    - connection_host: controller
    - require:
      - mysql_user: {{ pillar['IRONIC_DBUSER'] }}

Ironic fix-db-access.sh:
  cmd.run:
    - name: /usr/local/bin/fix-db-access.sh {{ pillar['IRONIC_DBUSER'] }} {{ pillar['IRONIC_DBPASS'] }} {{ pillar['DATABASE'] }} ironic
    - user: root
    - unless: test -f /etc/salt/.{{ pillar['IRONIC_DBUSER'] }}-access-fixed

ironic-initdb:
  cmd.run:
    - name: su -s /bin/sh -c "ironic-dbsync --config-file /etc/ironic/ironic.conf create_schema" ironic && touch /etc/ironic/.already_synced
    - unless: test -f /etc/ironic/.already_synced
    - user: root
    - watch_in:
      - service: ironic-api
      - service: ironic-conductor

Ironic tenants:
  keystone.tenant_present:
    - names:
      - ironic

ironic_user:
  keystone.user_present:
    - name: ironic
    - password: {{ pillar['IRONIC_PASS'] }}
    - email: infradevs@flugel.it
    - roles:
      - service:
        - admin
      - require:
        - keystone: Ironic tenants

ironic_keystone_service:
  keystone.service_present:
    - name: ironic
    - service_type: baremetal
    - description: Ironic bare metal provisioning service

ironic_keypoint_endpoint:
  keystone.endpoint_present:
    - name: ironic
    - publicurl: http://{{ grains["host"] }}:6385
    - internalurl: http://{{ grains["host"] }}:6385
    - adminurl: http://{{ grains["host"] }}:6385
    - region: FlugelitRegion

{%if "ironic-compute" in grains.get("roles", []) %}

/var/tmp/libvirt-ceph.xml:
  file.managed:
    - source: salt://openstack/ironic/files/libvirt-ceph.xml
    - template: jinja

libvirt-ceph-secret-define:
  cmd.run:
    - name: virsh secret-define --file /var/tmp/libvirt-ceph.xml
    - unless: virsh secret-list | grep ceph

libvirt-ceph-secret-set:
  cmd.run:
    - name: virsh secret-set-value --secret 457eb676-33da-42ec-9a8c-9293d545c337 --base64 $(ceph auth get-key client.cinder)

{%- endif %}
