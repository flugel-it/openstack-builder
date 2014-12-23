sahara_pkgs:
  - pkg.installed
    - pkgs:
      - python-setuptools
      - python-virtualenv
      - python-dev
      - python-pip

sahara:
  pip.installed: []
    - require: sahara_pkgs
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

ahara-guestagent:
  pip.installed

/etc/sahara:
  file.directory:
    - user: sahara
    - group: sahara
    - mode: 755

/etc/sahara/sahara.conf:
  file.managed:
    - source: salt://openstack/sahara/files/sahara.conf
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: sahara
    - group: sahara
    - mode: 755

keystone-openstack-service:
  keystone.service_present:
    - name: sahara
    - service_type: data_processing
    - description: Sahara Data Processing

keystone-endpoint:
  keystone.endpoint_present:
    - name: sahara
    - publicurl: http://{{ salt.openstack.get_controller() }}:8386/v1.1/%(tenant_id)s
    - internalurl: http://{{ salt.openstack.get_controller() }}:8386/v1.1/%(tenant_id)s
    - adminurl: http://{{ salt.openstack.get_controller() }}:8386/v1.1/%(tenant_id)s
    - region: {{ pillar.openstack.region }}
