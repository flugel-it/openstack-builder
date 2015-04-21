
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

