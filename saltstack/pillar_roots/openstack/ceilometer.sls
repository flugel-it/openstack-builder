
openstack:
  ceilometer:
    enabled: true
    controller_pkgs:
      - ceilometer-api
      - ceilometer-collector
      - ceilometer-agent-central
      - ceilometer-agent-notification
      - ceilometer-alarm-evaluator
      - ceilometer-alarm-notifier

