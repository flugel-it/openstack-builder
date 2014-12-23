
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
    - password: {{ pillar.db_root_pass }}
    - require:
      - service: mysql

/etc/salt/minion.d/mysql.conf:
  file.managed:
    - source: salt://mysql/files/mysql.minion.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 640
    - require:
      - mysql_user: mysql
    - watch_in:
      - service: salt-minion
  
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

