
{% if grains.get("os") in [ "CentOS", "Redhat" ] %}

mongodb-repo:
  pkgrepo.managed:
    - humanname: mongodb
    - baseurl: http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/
    - gpgcheck: 0
    - enabled: 1

#Not sure why pkg.installed doesn't work in CentOS 6 for MongoDB !?
mongodb:
  cmd.run:
    - name: yum install -y mongodb-org-server mongodb-org-shell mongodb-org-tools
    - unless: test -f /usr/bin/mongod
    - require:
      - pkgrepo: mongodb-repo

{% else %}

mongodb-repo:
  pkgrepo.managed:
    - humanname: mongodb-repo
    - name: deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen
    - dist: dist
    - file: /etc/apt/sources.list.d/mongodb-repo.list
    - keyid: 7F0CEB10
    - keyserver: keyserver.ubuntu.com

mongodb:
  pkg.installed:
    - pkgs:
      - mongodb-org-server
      - mongodb-org-shell
      - mongodb-org-tools
    - require:
      - pkgrepo: mongodb-repo

{% endif %}

mongod:
  service.running:
    - enable: true
    - require:
{% if grains.get("os") in [ "CentOS", "Redhat" ] %}
      - cmd: mongodb
{% else %}
      - pkg: mongodb
{% endif %}

{%- if grains.get("environment") != "vagrant" %}

{{ pillar["nrpe_conf_dir"] }}/mongodb.cfg:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://mongodb/files/mongodb-nrpe.conf
    - template: jinja
    - watch_in:
      - service: nrpe

/etc/dws-backup.d/mongo-backup.sh:
  file.managed:
    - source: salt://mongodb/files/mongo-backup.sh
    - mode: 755

{% endif %}

/etc/mongod.conf:
  file.append:
    - text: smallfiles = true
    - watch_in:
      - service: mongod

