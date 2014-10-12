
keystone_pkg:
  pkg.installed:
    -name: {{ pillar['keystone_pkg'] }}
    -name: {{ pillar['rabbitmq-server_pkg'] }}
