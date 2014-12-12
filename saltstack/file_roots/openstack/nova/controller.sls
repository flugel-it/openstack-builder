
{%- for pkg in pillar.pkgs.nova_controller %}

openstack-{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}

{{ pkg }}-service:
  service.running:
    - name: {{ pkg }}
    - watch:
      - file: /etc/nova/nova.conf

{%- endfor %}

/root/.nova:
  file.managed:
    - source: salt://openstack/nova/files/dot_nova
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: root
    - group: root
    - mode: 600

openstack-nova-db:
  mysql_database.present:
    - name: nova
  mysql_user.present:
    - name: nova
    - password: {{ pillar.openstack.nova_dbpass }}
    - host: "%"
  mysql_grants.present:
    - grant: all privileges
    - database: nova.*
    - user: nova
    - password: {{ pillar.openstack.nova_dbpass }}
    - host: "%"

openstack-nova-initdb:
  cmd.run:
    - name: nova-manage db sync && touch /etc/nova/.already_synced
    - unless: test -f /etc/nova/.already_synced
    - user: nova

openstack-nova-user:
  keystone.user_present:
    - name: nova
    - password: {{ pillar.openstack.nova_pass }}
    - email: infradevs@flugel.it
    - roles:
      - service:
        - admin

openstack-nova-keystone-service:
  keystone.service_present:
    - name: nova
    - service_type: compute
    - description: Openstack Compute Service

openstack-nova-keypoint-endpoint:
  keystone.endpoint_present:
    - name: nova
    - publicurl: http://{{ salt.openstack.get_controller() }}:8774/v2/%(tenant_id)s
    - internalurl: http://{{ salt.openstack.get_controller() }}:8774/v2/%(tenant_id)s
    - adminurl: http://{{ salt.openstack.get_controller() }}:8774/v2/%(tenant_id)s
    - region: flugelRegion

