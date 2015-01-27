
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

/etc/apache2/sites-enabled/000-default.conf:
  file.absent

/etc/apache2/conf-enabled/openstack-dashboard.conf:
  file.absent

/etc/apache2/sites-available/openstack.conf:
  file.managed:
    - source: salt://openstack/horizon/files/openstack-dashboard.conf
    - template: jinja
    - mode: 644
    - watch_in:
      - service: apache2

/etc/apache2/sites-available/ssl-redirect.conf:
  file.managed:
    - source: salt://openstack/horizon/files/ssl-redirect.conf
    - template: jinja
    - mode: 644
    - watch_in:
      - service: apache2

openstack-dashboard-enable:
  cmd.run:
    - name: a2ensite openstack
    - unless: test -f /etc/apache2/sites-enabled/openstack.conf
    - watch_in:
      - service: apache2

openstack-dashboard-ssl-direct:
  cmd.run:
    - name: a2ensite ssl-redirect
    - unless: test -f /etc/apache2/sites-enabled/ssl-redirect.conf
    - require:
      - file: /etc/apache2/sites-available/ssl-redirect.conf
    - watch_in:
      - service: apache2

openstack-dashboard-ssl:
  cmd.run:
    - name: a2enmod ssl
    - unless: test -f /etc/apache2/mods-enabled/ssl.conf
    - watch_in:
      - service: apache2

openstack-dashboard-rewrite:
  cmd.run:
    - name: a2enmod rewrite
    - unless: test -f /etc/apache2/mods-enabled/rewrite.conf
    - watch_in:
      - service: apache2

