
openstack:
  ceilometer:
    enabled: true
    controller_pkgs:
      - ceilometer-agent-central
      - ceilometer-agent-notification
      - ceilometer-api
      - ceilometer-collector
      - ceilometer-alarm-evaluator
      - ceilometer-alarm-notifier

