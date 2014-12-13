from IPy import IP

def get_controller():
    return "openstack-controller.openstack.flugel.it"

def get_public_ip():
    for ip in __grains__["ipv4"]:
        if IP(ip).iptype() == "PUBLIC":
            return ip

    return False

def get_private_ip():
    for ip in __grains__["ipv4"]:
        if IP(ip).iptype() == "PRIVATE":
            return ip

    return False

