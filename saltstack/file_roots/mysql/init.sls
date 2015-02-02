
# Required for Salt to manage MySQL
{{ pillar.pkgs.python_mysqldb }}:
  pkg.installed:
    - watch_in:
      - service: salt-minion

mysql:
  pkg.installed:
    - pkgs:
      - {{ pillar.pkgs.mysql_server }}
      - {{ pillar.pkgs.mysql_client }}
    - require:
      - pkg: {{ pillar.pkgs.python_mysqldb }}
  service.running:
    - enable: true
  mysql_user.present:
    - name: root
    - password: {{ pillar.get("mysql.pass") }}
    - require:
      - service: mysql

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

