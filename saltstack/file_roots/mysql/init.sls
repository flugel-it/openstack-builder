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




# Required for Salt to manage MySQL
{{ pillar.pkgs.python_mysqldb }}:
  pkg.installed

mysql:
  pkg.installed:
    - pkgs:
      - {{ pillar.pkgs.mysql_server }}
      - {{ pillar.pkgs.mysql_client }}
    - require:
      - pkg: {{ pillar.pkgs.python_mysqldb }}
  service.running:
    - enable: true

{%- if pillar.get("mysql.pass") %}

# None or False are converted to string ("None", "False") and this breaks
# the passwd change. So, use null in that case.
{%- if grains.get("mysql.pass") in [ "None", None, False ] %}
{%- set mysql_pass = "null" %}
{%- else %}
{%- set mysql_pass = grains.get("mysql.pass") %}
{%- endif %}
mysql-root-pass:
  mysql_user.present:
    - connection_pass: {{ mysql_pass }}
    - name: root
    - password: {{ pillar.get("mysql.pass") }}
    - require:
      - service: mysql

# Chicken and egg problem fix. mysql.pass pillar is the password that the 
# mysql module uses to authenticate. But... in a fresh installed server,
# there is no passwd. So, we use the mysql.pass grain to store the current
# one (null the first run) and then we update it if the pillar is updated.
# Makes sense? and let me know if I'm wrong. Diego.
{%- if grains.get("mysql.pass") != pillar.get("mysql.pass") %}
{%- do salt.grains.setval("mysql.pass", pillar.get("mysql.pass")) %}
{%- endif %}

{%- endif %}

{{ pillar.paths.my_cnf }}:
  file.managed:
    - source: salt://mysql/files/my.cnf.template
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: mysql
    - watch_in:
      - service: mysql

/etc/salt/minion.d/mysql.conf:
  file.absent

