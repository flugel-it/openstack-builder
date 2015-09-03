
clear_cache:
  salt.runner:
    - name: cache.clear_all

sync_all:
  salt.function:
    - tgt: 'cluster_name:{{ pillar.cluster_name }}'
    - tgt_type: grain
    - name: saltutil.sync_all
    - require:
      - salt: clear_cache
    - timeout: 120
    - failhard: True

refresh_pillar:
  salt.function:
    - tgt: 'cluster_name:{{ pillar.cluster_name }}'
    - tgt_type: grain
    - name: saltutil.refresh_pillar
    - timeout: 60
    - failhard: True
    - require:
      - salt: clear_cache

stage1:
  salt.state:
    - tgt: 'cluster_name:{{ pillar.cluster_name }}'
    - tgt_type: grain
    - timeout: 300
    - failhard: True
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
    - timeout: 300
    - failhard: True
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
    - timeout: 300
    - failhard: True
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
    - timeout: 300
    - failhard: True
    - sls:
      - openstack
      - openstack.controller
      - openstack.keystone
    - require:
      - salt: controller1

highstate_all:
  salt.state:
    - tgt: 'cluster_name:{{ pillar.cluster_name }}'
    - tgt_type: grain
    - highstate: True
    - timeout: 600
    - failhard: True
    - require:
      - salt: controller2

