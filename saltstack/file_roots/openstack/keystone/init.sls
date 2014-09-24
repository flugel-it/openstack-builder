
openstack-keystone-pkgs:
  pkg.installed:
    - pkgs:
      - mysql-server
      - rabbitmq-server
      - keystone

rabbit_user:
  rabbitmq_user.present:
    - name: guest
    - password: {{ pillar["rabbit_pwd"] }}

