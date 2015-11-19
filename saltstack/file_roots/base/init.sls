{%- set hos_familytname = grains['id'] %}

/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 750

base-pkgs:
  pkg.installed:
    - pkgs:
      - ssh
      - screen
      - strace
      - tcpdump
      - ntp
      - sysstat
      - dstat
      - vim
      - unzip
      - git
      - psutils
      - bridge-utils
      - python-pip
      - vlan
      - python-pip
      - ifenslave
      - ethtool
      - arping
      - curl

ntp:
  service.running:
    - enable: true

{% if grains.get("os_family") == "Debian" %}

/etc/apt/sources.list:
  file.replace:
    - pattern: '^# *(deb http://.*)'
    - repl: '\g<1>'

apt-get update:
  cmd.wait:
    - order: 0
    - watch:
      - file: /etc/apt/sources.list

/etc/default/sysstat:
  file.replace:
    - pattern: ^ENABLED.*
    - repl: ENABLED="true"
    - watch_in:
      - service: sysstat

{% endif %}

{% if grains.get("os_family") in [ "RedHat", "Redhat" ] %}

selinux-disabled:
  file:
    - replace
    - name: /etc/selinux/config
    - pattern: SELINUX=.*
    - repl: SELINUX=disabled

{% endif %}

sysstat:
  service.running:
    - enable: true
    - watch:
      - pkg: base-pkgs

#OpenSSL always the latest version, Heartbleed protection :)
{% if grains.get("os_family") == "RedHat" %}

openssl:
  pkg.latest

{% elif grains.get("os_family") == "Debian" %}

openssl:
  pkg.latest

libssl1.0.0:
  pkg.latest

{% endif %}

/root/.ssh/authorized_keys:
  file.managed:
    - user: root
    - group: root
    - mode: 400
    - source: salt://base/files/root_authorized_keys

/etc/resolv.conf:
  file.managed:
    - contents: "nameserver 8.8.8.8\n"

#XXX: add the profiles required for OpenSack and Ceph.
apparmor:
  pkg.purged

{%- if grains.get('apt-proxy-address') == None %}
/etc/apt/apt.conf.d/01proxy:
  file.absent
{%- else %}
/etc/apt/apt.conf.d/01proxy:
  file.managed:
    - mode: 0644
    - template: jinja
    - source: salt://base/files/01proxy
{%- endif %}
