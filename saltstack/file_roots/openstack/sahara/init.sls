python-setuptools:
  pkg.installed
python-virtualenv:
  pkg.installed
python-dev:
  pkg.installed
python-pip:
  pkg.installed

sahara:
  pip.installed: []
  group.present:
    - gid: 10000
  user.present:
    - shell: /bin/false
    - home: /var/lib/sahara
    - createhome: false
    - uid: 10000
    - gid: 10000

sahara-dashboard:
  pip.installed

python-saharaclient:
  pip.installed

sahara-image-elements:
  pip.installed

sahara-service:
  service.running:
    - name: sahara
    - watch:
      - file: /etc/sahara/sahara.conf

/etc/sahara:
  file.directory:
    - user: sahara
    - group: sahara
    - mode: 755

/etc/init/sahara.conf:
  file.managed:
    - source: salt://openstack/sahara/files/init-sahara.conf
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: root
    - group: root
    - mode: 644

/etc/sahara/sahara.conf:
  file.managed:
    - source: salt://openstack/sahara/files/sahara.conf
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: sahara
    - group: sahara
    - mode: 755

openstack-sahara-db:
  mysql_database.present:
    - name: sahara
  mysql_user.present:
    - name: sahara
    - password: {{ pillar.openstack.sahara_dbpass }}
    - host: "%"
  mysql_grants.present:
    - grant: all privileges
    - database: sahara.*
    - user: sahara
    - password: {{ pillar.openstack.sahara_dbpass }}
    - host: "%"

openstack-sahara-initdb:
  cmd.run:
    - name: sahara-db-manage --config-file /etc/sahara/sahara.conf upgrade head && touch /etc/sahara/.already_synced
    - unless: test -f /etc/sahara/.already_synced
    - user: sahara

openstack-sahara-user:
  keystone.user_present:
    - name: sahara
    - password: {{ pillar.openstack.sahara_pass }}
    - email: infradevs@flugel.it
    - roles:
      - service:
        - admin

sahara-service-endpoint:
  keystone.service_present:
    - name: sahara
    - service_type: data_processing
    - description: Sahara Data Processing

sahara-endpoint:
  keystone.endpoint_present:
    - name: sahara
    - publicurl: http://{{ salt.openstack.get_controller_public() }}:8386/v1.1/%(tenant_id)s
    - internalurl: http://{{ salt.openstack.get_controller() }}:8386/v1.1/%(tenant_id)s
    - adminurl: http://{{ salt.openstack.get_controller() }}:8386/v1.1/%(tenant_id)s
    - region: {{ pillar.openstack.region }}
