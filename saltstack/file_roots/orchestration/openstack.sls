
sync_all:
  salt.function:
    - tgt: 'cluster_name:{{ pillar.cluster_name }}'
    - tgt_type: grain
    - name: saltutil.sync_all

refresh_pillar:
  salt.function:
    - tgt: 'cluster_name:{{ pillar.cluster_name }}'
    - tgt_type: grain
    - name: saltutil.refresh_pillar

stage1:
  salt.state:
    - tgt: 'cluster_name:{{ pillar.cluster_name }}'
    - tgt_type: grain
    - sls:
      - base
      - openstack
      - salt-minion
    - require:
      - salt: sync_all
      - salt: refresh_pillar

stage2:
  salt.state:
    - tgt: 'cluster_name:{{ pillar.cluster_name }}'
    - tgt_type: grain
    - sls:
      - salt-minion
      - hostsfile
      - openstack.minion
    - require:
      - salt: stage1

controller1:
  salt.state:
    - tgt: 'G@cluster_name:{{ pillar.cluster_name }} and G@roles:openstack-controller'
    - tgt_type: compound
    - sls:
      - salt-minion
      - mysql
      - rabbitmq
    - require:
      - salt: stage2

controller2:
  salt.state:
    - tgt: 'G@cluster_name:{{ pillar.cluster_name }} and G@roles:openstack-controller'
    - tgt_type: compound
    - sls:
      - openstack
      - openstack.controller
      - openstack.keystone
    - require:
      - salt: stage1

highstate_all:
  salt.state:
    - tgt: 'cluster_name:{{ pillar.cluster_name }}'
    - tgt_type: grain
    - highstate: True
    - require:
      - salt: controller2

