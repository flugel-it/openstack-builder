
neutron-plugin-ml2:
  pkg.installed
  
python-neutronclient:
  pkg.installed

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
    - context:
      local_ip: {{ salt.openstack.get_private_ip() }}
    - user: neutron
    - group: neutron
    - mode: 640

