
pkgs:
    {% if grains['os_family'] == 'RedHat' %}
    vim: vim-enhanced
    screen: screen
    {% elif grains['os_family'] == 'Debian' %}
    vim: vim
    screen: screen
    python-software-properties: python-software-properties
    mysql-server: mysql-server
    keystone_pkg: keystone
    {% endif %}
