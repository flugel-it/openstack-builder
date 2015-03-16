    This file is part of Openstack-Builder.

    Openstack-Builder is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Openstack-Builder is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Openstack-Builder.  If not, see <http://www.gnu.org/licenses/>.

    Copyright flugel.it LLC
    Authors: Luis Vinay <luis@flugel.it>
             Diego Woitasen <diego@flugel.it>





openstack-horizon-pkgs:
  pkg.installed:
    - pkgs:
      - apache2
      - libapache2-mod-wsgi
      - memcached
      - python-memcache
      - openstack-dashboard

local_settings.py:
  file.managed:
    - source: salt://openstack/horizon/files/local_settings.py
    - template: jinja
    - content:
      controller: {{ salt.openstack.get_controller() }}
      controller_public: {{ salt.openstack.get_controller_public() }}
    - name: /etc/openstack-dashboard/local_settings.py
    - mode: 644
    - watch_in:
      - service: apache2

/etc/apache2/sites-enabled/000-default.conf:
  file.absent:
    - watch_in:
      - service: apache2

/etc/apache2/conf-enabled/openstack-dashboard.conf:
  file.absent:
    - watch_in:
      - service: apache2

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

{%- if pillar.get('customlookandfeel') %}

logo:
  file.managed:
    - source: salt://openstack/horizon/files/{{ grains['cluster_name'] }}/logo.png
    - name: /usr/share/openstack-dashboard/openstack_dashboard/static/dashboard/img/logo.png
    - mode: 644

logo-splash:
  file.managed:
    - source: salt://openstack/horizon/files/{{ grains['cluster_name'] }}/logo-splash.png
    - name: /usr/share/openstack-dashboard/openstack_dashboard/static/dashboard/img/logo-splash.png
    - mode: 644

favicon:
  file.managed:
    - source: salt://openstack/horizon/files/{{ grains['cluster_name'] }}/favicon.ico
    - name: /usr/share/openstack-dashboard/openstack_dashboard/static/dashboard/img/favicon.ico
    - mode: 644
{% endif %}

apache2:
  service.running:
    - enable: True

# Removal will fail if apache2 is not runing
openstack-dashboard-ubuntu-theme:
   pkg.removed:
     - require:
       - service: apache2

