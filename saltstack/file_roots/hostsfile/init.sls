
/etc/hosts:
  file.managed:
    - source: salt://hostsfile/files/hosts.jinja
    - mode: 644
    - template: jinja
    - unless: test -f /etc/salt/.hosts_ignore

