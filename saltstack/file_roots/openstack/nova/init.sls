
python-novaclient:
  pkg.installed

nova-common:
  pkg.installed

/var/lib/nova/nova.db:
  file.absent

/etc/nova:
  file.directory:
    - user: nova
    - group: nova
    - mode: 750

/var/log/nova/:
  file.directory:
    - user: nova
    - group: nova
    - mode: 755

/etc/nova/nova.conf:
  file.managed:
    - template: jinja
    - source: salt://openstack/nova/files/nova.conf
    - context:
      controller: {{ salt.openstack.get_controller() }}
      controller_public: {{ salt.openstack.get_controller_public() }}
      public_ip: {{ salt.openstack.get_public_ip() }}
      private_ip: {{ salt.openstack.get_private_ip() }}

