
<<<<<<< HEAD
openstack-glance-pkgs:
  pkg.installed:
    - pkgs:
      - {{ pillar["glance_pkg"] }}
      - mysql-client

/var/lib/glance/glance.sqlite:
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
=======
{% if "ironic" in grains.get("roles", [])%}
openstack-ironic-pkgs:
  pkg.installed:
    - pkgs:
      - ironic-api
      - ironic-conductor
      - python-ironicclient

ironic-api:
  pkg:
    - installed
  service:
    - running
    - enable: True

ironic-conductor:
  pkg:
    - installed
  service:
    - running
    - enable: True

python-ironicclient:
  pkg:
    - installed

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
>>>>>>> 61b9e060f0b534f6d3b52f271da566df2d2be132
    - template: jinja
    - user: root
    - group: root
    - mode: 600

<<<<<<< HEAD
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
=======
/var/log/ironic/:
  file.directory:
    - user: ironic
    - group: ironic
    - mode: 755

ironic_db:
  mysql_database.present:
    - connection_pass: {{ pillar['DATABASE'] }}

    - name: ironic
    - connection_host: controller
  mysql_user.present:
    - name: {{ pillar['IRONIC_DBUSER'] }}
    - password: {{ pillar['IRONIC_DBPASS'] }}
    - allow_passwordless: False
    - connection_host: controller
>>>>>>> 61b9e060f0b534f6d3b52f271da566df2d2be132
    - host: "%"
    - connection_pass: {{ pillar['DATABASE'] }}
  mysql_grants.present:
    - grant: all privileges
<<<<<<< HEAD
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
=======
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
    - name: ironic-dbsync --config-file /etc/ironic/ironic.conf create_schema && touch /etc/ironic/.already_synced
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
>>>>>>> 61b9e060f0b534f6d3b52f271da566df2d2be132
    - email: infradevs@flugel.it
    - roles:
      - service:
        - admin
      - require:
<<<<<<< HEAD
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
=======
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
    - region: flugelRegion

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
>>>>>>> 61b9e060f0b534f6d3b52f271da566df2d2be132
