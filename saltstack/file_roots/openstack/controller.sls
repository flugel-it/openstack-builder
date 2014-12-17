
openstack-rabbit-user:
  rabbitmq_user.present:
    - name: openstack
    - password: {{ pillar.openstack.rabbit_pass }}
    - force: True
    - tags: 
      - user
    - perms:  
      - '/':
        - '.*'
        - '.*'
        - '.*'


