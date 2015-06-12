
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
    os.system("service salt-minion restart")

    return "OK"

