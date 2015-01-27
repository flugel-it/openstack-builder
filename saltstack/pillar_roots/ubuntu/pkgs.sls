
pkgs:
  vim: vim
  mysql_server: mysql-server
  mysql_client: mysql-client
  python_mysqldb: python-mysqldb
  rabbit_server: rabbitmq-server
  python_software_properties: python-software-properties

  glance: glance
  keystone: keystone
  rabbitmq_server: rabbitmq-server
  nova_controller:
    - nova-api
    - nova-cert
    - nova-conductor
    - nova-consoleauth
    - nova-novncproxy
    - nova-scheduler
  nova_compute:
    - nova-compute

