
neutron-server:
  pkg.installed
  
neutron-plugin-ml2:
  pkg.installed
  
python-neutronclient:
  pkg.installed

/etc/salt/minion.d/neutron-minion.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/neutron/files/neutron.minion.conf
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - watch_in:
      - service: salt-minion

/root/.neutron:
  file.managed:
    - source: salt://openstack/neutron/files/dot_neutron
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: root
    - group: root
    - mode: 600

/var/log/neutron/:
  file.directory:
    - user: neutron
    - group: neutron
    - mode: 755

/etc/neutron/neutron.conf:
  file.managed:
    - source: salt://openstack/neutron/files/neutron.conf
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: neutron
    - group: neutron
    - mode: 640

neutron-service:
  service.running:
    - name: neutron-server
    - enable: true
    - watch:
      - file: /etc/neutron/neutron.conf

neutron_db:
  mysql_database.present:
    - name: neutron
  mysql_user.present:
    - name: neutron
    - password: {{ pillar.openstack.neutron_dbpass }}
    - host: "%"
  mysql_grants.present:
    - grant: all privileges
    - database: neutron.*
    - user: neutron
    - host: "%"

neutron-user:
  keystone.user_present:
    - name: neutron
    - password: {{ pillar.openstack.neutron_pass }}
    - email: infradevs@flugel.it
    - roles:
      - service:
        - admin

neutron-keystone-service:
  keystone.service_present:
    - name: neutron
    - service_type: image
    - description: Openstack Network Service
    - watch_in:
      - service: neutron-service

neutron-keypoint-endpoint:
  keystone.endpoint_present:
    - name: neutron
    - publicurl: http://{{ salt.openstack.get_controller() }}:9696
    - internalurl: http://{{ salt.openstack.get_controller() }}:9696
    - adminurl: http://{{ salt.openstack.get_controller() }}:9696
    - watch_in:
      - service: neutron-service

