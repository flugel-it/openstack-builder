
python-novaclient:
  pkg.installed

/etc/salt/minion.d/nova-minion.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/nova/files/nova.minion.conf
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - watch_in:
      - service: salt-minion

/var/lib/nova/nova.db:
  file.absent

/etc/nova/nova.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/nova/files/nova.conf
    - context:
      controller: {{ salt.openstack.get_controller() }}
      public_ip: {{ salt.openstack.get_public_ip() }}
      private_ip: {{ salt.openstack.get_private_ip() }}

/var/log/nova/:
  file.directory:
    - user: nova
    - group: nova
    - mode: 755

