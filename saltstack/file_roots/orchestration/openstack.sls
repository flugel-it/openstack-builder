    This file is part of Openstack-Builder.

    Openstack-Builder is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Openstack-Builder is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Openstack-Builder.  If not, see <http://www.gnu.org/licenses/>.

    Copyright flugel.it LLC
    Authors: Luis Vinay <luis@flugel.it>
             Diego Woitasen <diego@flugel.it>




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

refresh_pillar:
  salt.function:
    - tgt: 'cluster_name:{{ pillar.cluster_name }}'
    - tgt_type: grain
    - name: saltutil.refresh_pillar
    - require:
      - salt: clear_cache

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
      - salt: controller1

highstate_all:
  salt.state:
    - tgt: 'cluster_name:{{ pillar.cluster_name }}'
    - tgt_type: grain
    - highstate: True
    - require:
      - salt: controller2

