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




import os

def set_hostname(hostname):
    open("/etc/salt/minion_id", "w").write(hostname + "\n")
    open("/etc/hostname", "w").write(hostname + "\n")

    try:
        os.unlink("/etc/init/flugel-first-boot.conf")
    except OSError:
        pass
    os.system("hostname " + hostname)
    os.system("sed -i 's/^id:.*/id: %s/' /etc/salt/minion" % (hostname))
    os.system("restart salt-minion")

    return "OK"

