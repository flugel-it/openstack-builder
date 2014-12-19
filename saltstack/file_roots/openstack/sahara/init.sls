
python-pip:
  pkg.installed

sahara:
  pip.installed: []
  group.present:
    - gid: 10000
  user.present:
    - shell: /bin/false
    - home: /var/lib/sahara
    - createhome: false
    - uid: 10000
    - gid: 10000

sahara-dashboard:
  pip.installed

/etc/sahara:
  file.directory:
    - user: sahara
    - group: sahara
    - mode: 755

/etc/sahara/sahara.conf:
  file.managed:
    - source: salt://openstack/sahara/files/sahara.conf
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
    - user: sahara
    - group: sahara
    - mode: 755

