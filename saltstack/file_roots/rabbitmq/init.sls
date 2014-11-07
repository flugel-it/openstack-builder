# - check why it cannot modify users, only create/remove works
#

rabbitmq-server:
  pkg.installed:
    - pkgs:
      - {{ pillar["rabbitmq-server_pkg"] }}

rabbit_query_user:
  rabbitmq_user.present:
    - name: {{ pillar["RABBIT_USER"] }}
    - password: {{ pillar["RABBIT_PASS"] }}
    - force: True
    - tags: administrator,monitoring,user
    - perms:
      - '/':
        - '.*'
        - '.*'
        - '.*'

rabbit-remove-guest-user:
    rabbitmq_user.absent:
        - name: 'guest'

