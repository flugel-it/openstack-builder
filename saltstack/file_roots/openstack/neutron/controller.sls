
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

/etc/neutron/:
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

/etc/neutron/plugins/ml2/ml2_conf.ini:
  file.managed:
    - source: salt://openstack/neutron/files/ml2_conf.ini
    - template: jinja
    - user: neutron
    - group: neutron
    - mode: 640

neutron-service:
  service.running:
    - name: neutron-server
    - enable: true
    - watch:
      - file: /etc/neutron/neutron.conf
      - file: /etc/neutron/plugins/ml2/ml2_conf.ini

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

neutron-initdb:
  cmd.run:
    - name: >
        neutron-db-manage --config-file /etc/neutron/neutron.conf 
        --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade juno && 
        touch /etc/neutron/.already_synced
    - user: neutron
    - unless: test -f /etc/neutron/.already_synced

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
    - service_type: network
    - description: Openstack Network Service
    - watch_in:
      - service: neutron-service

neutron-keystone-endpoint:
  keystone.endpoint_present:
    - name: neutron
    - publicurl: http://{{ salt.openstack.get_controller() }}:9696
    - internalurl: http://{{ salt.openstack.get_controller() }}:9696
    - adminurl: http://{{ salt.openstack.get_controller() }}:9696
    - require:
      - keystone: neutron-keystone-service
    - watch_in:
      - service: neutron-service


