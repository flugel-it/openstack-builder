
rabbitmq-server:
  pkg.installed:
    - name: {{ pillar.pkgs.rabbit_server }}

rabbit-remove-guest-user:
  rabbitmq_user.absent:
    - name: 'guest'

