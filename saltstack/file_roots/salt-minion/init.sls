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




#pkgs required by stock and custom modules
salt-mine-pkgs:
  pkg.installed:
    - pkgs:
      - python-dev
      - python-setuptools
      - build-essential

python-pip:
  pkg.removed

python-psutil:
  pkg.removed

python-ipy:
  pkg.removed

python-netifaces:
  pkg.removed

pip-install:
  cmd.run:
    - name: easy_install pip
    - unless: test -f /usr/local/bin/pip
    - reload_modules: True
    - require:
      - pkg: salt-mine-pkgs

{%- for pip_pkg in [ "psutil", "IPy", "netifaces" ] %}

{{ pip_pkg }}:
  pip.installed:
    - require:
      - cmd: pip-install
    - watch_in:
      - service: salt-minion

{%- endfor %}

salt-minion:
  service.running:
    - enable: true

salt-mine:
  file.managed:
    - name: /etc/salt/minion.d/mine.conf
    - source: salt://salt-minion/files/salt-mine.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: salt-minion

salt-tcp:
  file.managed:
    - name: /etc/salt/minion.d/tcp.conf
    - source: salt://salt-minion/files/tcp.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: salt-minion

