
openstack-keystone-pkgs:
  pkg.installed:
    - pkgs:
      - mysql-server
      - {{ pillar["rabbitmq-server_pkg"] }}
      - {{ pillar["keystone_pkg"] }}

/etc/keystone/keystone.conf:
  file.managed:
    - source: salt:///base/files/keystone.conf
    - user: root
    - group: root
    - mode: 640
    - template: jinja
