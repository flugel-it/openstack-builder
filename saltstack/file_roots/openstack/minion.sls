
# We need it now, because it's required to render some templates using
# the keystone Salt module.
python-keystoneclient:
  pkg.installed

/etc/salt/minion.d/openstack.conf:
  file.managed:
    - source: salt://openstack/files/openstack.minion.conf
    - template: jinja
    - context:
      controller: {{  salt.openstack.get_controller() }}
    - watch_in:
      - service: salt-minion

