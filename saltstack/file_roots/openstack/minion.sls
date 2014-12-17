
/etc/salt/minion.d/openstack.conf:
  file.managed: 
    - template: jinja
    - source: salt://openstack/files/openstack.minion.conf
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - watch_in:
      - service: salt-minion

