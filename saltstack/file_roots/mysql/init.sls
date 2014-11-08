
python-mysqldb:
  pkg.installed:
    - watch_in:
      - service: salt-minion

mysql:
  pkg.installed:
    - pkgs:
      - mysql-server
      - mysql-client
    - require:
      - pkg: python-mysqldb
  service.running:
    - enable: true
  mysql_user:
    - present
    - name: root
    - password: {{ pillar['DATABASE'] }}
    - require:
      - service: mysql
  
/etc/mysql/my.cnf:
  file.managed:
    - source: salt://mysql/files/my.cnf.template
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: mysql
    - watch_in:
      - service: mysql
