from IPy import IP

mine_get = __salt__['mine.get']

def get_controller():
    grains = mine_get("roles:openstack-controller", "grains.item",
            expr_form="grain")
    for minion, grains in grains.iteritems():
        return grains.get("fqdn")

    return False

def get_controller_ip():
    grains = mine_get("roles:openstack-controller", "grains.item",
            expr_form="grain")
    for minion, grains in grains.iteritems():
        for ip in __grains__["ipv4"]:
            if IP(ip).iptype() == "PRIVATE":
                return ip

    return False

def has_role(role):
    return role in __grains__.get("roles", [])

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

def external_iface():
    try:
        return __pillar__["openstack"]["external_iface"]
    except KeyError:
        for iface, ips in __grains__["ip4_interfaces"].iteritems():
            for ip in ips:
                if IP(ip).iptype() == "PUBLIC":
                    return iface

    return False

