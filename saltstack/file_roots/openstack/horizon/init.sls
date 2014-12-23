
openstack-horizon-pkgs:
  pkg.installed:
    - pkgs:
      - apache2
      - libapache2-mod-wsgi
      - memcached
      - python-memcache
      - openstack-dashboard

apache2:
  service.running:
    - enable: True

local_settings.py:
  file.managed:
    - source: salt://openstack/horizon/files/local_settings.py
    - template: jinja
    - content:
      controller: {{ salt.openstack.get_controller() }}
    - name: /etc/openstack-dashboard/local_settings.py
    - mode: 644
    - watch_in:
      - service: apache2

