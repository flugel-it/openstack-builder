

python-heatclient:
  pkg.installed

{%- for pkg in [ "heat-api", "heat-api-cfn", "heat-engine" ] %}

{{ pkg }}:
  pkg.installed: []
  service.running:
    - watch:
      - file: /etc/heat/heat.conf

{%- endfor %}

/etc/heat:
  file.directory:
    - user: heat
    - group: heat
    - mode: 755

/etc/heat/heat.conf:
  file.managed:
    - source: salt://openstack/heat/files/heat.conf
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: heat
    - group: heat
    - mode: 644

/var/lib/heat/heat.db:
  file.absent

/root/.heat:
  file.managed:
    - source: salt://openstack/heat/files/dot_heat
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: root
    - group: root
    - mode: 600

/var/log/heat/:
  file.directory:
    - user: heat
    - group: heat
    - mode: 755

heat_db:
  mysql_database.present:
    - name: heat
  mysql_user.present:
    - name: heat
    - password: {{ pillar.openstack.heat_dbpass }}
    - host: "%"
  mysql_grants.present:
    - grant: all privileges
    - database: heat.*
    - user: heat
    - host: "%"

heat-initdb:
  cmd.run:
    - name: heat-manage db_sync && touch /etc/heat/.already_synced
    - unless: test -f /etc/heat/.already_synced
    - user: heat

heat_stack_user:
  keystone.role_present

heat_stack_owner:
  keystone.role_present

heat-user:
  keystone.user_present:
    - name: heat
    - tenant: service
    - password: {{ pillar.openstack.heat_pass }}
    - email: infradevs@flugel.it
    - roles:
      - service:
          - admin

heat-keystone-service:
  keystone.service_present:
    - name: heat
    - service_type: orchestration
    - description: Openstack Orchestration Service

heat-cfg-keystone-service:
  keystone.service_present:
    - name: heat-cfn
    - service_type: cloudformation
    - description: Openstack CloudFormation Service

heat-keystone-endpoint:
  keystone.endpoint_present:
    - name: heat
    - publicurl: http://{{ salt.openstack.get_controller_public() }}:8004/v1/%(tenant_id)s
    - internalurl: http://{{ salt.openstack.get_controller() }}:8004/v1/%(tenant_id)s
    - adminurl: http://{{ salt.openstack.get_controller() }}:8004/v1/%(tenant_id)s

heat-cfn-keystone-endpoint:
  keystone.endpoint_present:
    - name: heat-cfn
    - publicurl: http://{{ salt.openstack.get_controller_public() }}:8000/v1/%(tenant_id)s
    - internalurl: http://{{ salt.openstack.get_controller() }}:8000/v1/%(tenant_id)s
    - adminurl: http://{{ salt.openstack.get_controller() }}:8000/v1/%(tenant_id)s

