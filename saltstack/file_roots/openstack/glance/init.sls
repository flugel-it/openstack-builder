
openstack-glance:
  pkg.installed:
    - name: {{ pillar.pkgs.glance }}

/var/lib/glance/glance.db:
  file.absent

/root/.glance:
  file.managed:
    - source: salt://openstack/glance/files/dot_glance
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
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
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: glance
    - group: glance
    - mode: 640

/etc/glance/glance-registry.conf:
  file.managed:
    - source: salt://openstack/glance/files/glance-registry.conf
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: glance
    - group: glance
    - mode: 640

glance_db:
  mysql_database.present:
    - name: glance
  mysql_user.present:
    - name: glance
    - password: {{ pillar.openstack.glance_dbpass }}
    - host: "%"
  mysql_grants.present:
    - grant: all privileges
    - database: glance.*
    - user: glance
    - host: "%"

glance-initdb:
  cmd.run:
    - name: glance-manage db_sync && touch /etc/glance/.already_synced
    - unless: test -f /etc/glance/.already_synced
    - user: glance

glance-user:
  keystone.user_present:
    - name: glance
    - password: {{ pillar.openstack.glance_pass }}
    - email: infradevs@flugel.it
    - roles:
      - service:
          - admin

glance-keystone-service:
  keystone.service_present:
    - name: glance
    - service_type: image
    - description: Openstack Image Service

glance-keypoint-endpoint:
  keystone.endpoint_present:
    - name: glance
    - publicurl: http://{{ salt.openstack.get_controller_public() }}:9292
    - internalurl: http://{{ salt.openstack.get_controller() }}:9292
    - adminurl: http://{{ salt.openstack.get_controller() }}:9292

glance-download-cache:
  file.directory:
    - name: /var/cache/openstack-builder/

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

