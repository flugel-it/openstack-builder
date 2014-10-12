
rabbitmq-server:
  pkg.installed:
    -name: {{ pillar['rabbitmq-server_pkg'] }}
