
openstack-keystone-pkgs:
  pkg.installed:
    - pkgs:
      - mysql-server
      - {{ pillar["rabbitmq-server_pkg"] }}
      - {{ pillar["keystone_pkg"] }}

