
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
    - publicurl: http://{{ salt.openstack.get_controller() }}:9292
    - internalurl: http://{{ salt.openstack.get_controller() }}:9292
    - adminurl: http://{{ salt.openstack.get_controller() }}:9292

{%- for img in pillar.glance.default_images %}

glance-download-{{ img.slug }}-image:
  file.managed:
    - name: /var/tmp/{{ img.slug }}
    - source: {{ img.url }}
    - source_hash: {{ img.hash_url }}

glance-create-{{ img.slug }}-image:
  cmd.run:
    - name: >
        glance image-create --name "{{ img.name }}"
        --file /var/tmp/{{ img.slug}} 
        --disk-format {{ img.format}} 
        --container-format {{ img.container_format }} 
        --is-public True
    - unless: glance image-list | grep "{{ img.name }}"
    - env:
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ pillar.openstack.admin_pass }}
      - OS_TENANT_NAME: admin
      - OS_AUTH_URL: http://{{ salt.openstack.get_controller() }}:35357/v2.0

{%- endfor %}

