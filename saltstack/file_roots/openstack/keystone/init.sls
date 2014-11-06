
openstack-keystone-pkgs:
  pkg.installed:
    - pkgs:
      - mysql-server
      - {{ pillar["rabbitmq-server_pkg"] }}
      - {{ pillar["keystone_pkg"] }}
  user.present:
    - name: luis
    - uid: 1000 

/etc/keystone/keystone.conf:
  file.managed:
    #- name: /etc/keystone/keystone.conf
    - source: salt://openstack/keystone/files/keystone.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 640
    #- require:
      #- pkg: {{ pillar["keystone_pkg"] }}

/root/.keystone_supercredentials:
  file.managed:
    #- name: /root/.keystone_supercredentials
    - source: salt://openstack/keystone/files/dot_keystone_supercredentials
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    #- require:
      #- pkg: {{ pillar["keystone_pkg"] }}

/root/.keystone:
  file.managed:
    #- name: /root/.keystone
    - source: salt://openstack/keystone/files/dot_keystone
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    #- require:
      #- pkg: {{ pillar["keystone_pkg"] }}
