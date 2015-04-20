
{%- if pillar.openstack.ceilometer.enabled %}

ceilometer-agent-compute:
  pkg.installed: []
  service.running:
    - watch:
      - file: /etc/ceilometer/ceilometer.conf

/etc/ceilometer/ceilometer.conf:
  file.managed:
    - source: salt://openstack/ceilometer/files/ceilometer.conf
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - mode: 750

{%- endif %}
