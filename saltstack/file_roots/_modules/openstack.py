
from IPy import IP
import netifaces

def _get_controller():
    mine_get = __salt__['mine.get']
    #Compound match not supported by mine :(
    minions = mine_get("roles:openstack-controller", "grains.item",
            expr_form="grain")

    for minion, grains in minions.iteritems():
        if grains.get("cluster_name") == __grains__["cluster_name"]:
            return minion, grains

    return None, None

def get_controller():
    minion, grains = _get_controller()

    if minion is None:
        return None

    return grains.get("fqdn")

def get_controller_public():
    try:
        return __pillar__["openstack"]["controller_public"]
    except KeyError:
        minion, grains = _get_controller()

        if minion is None:
            return None

        return grains.get("fqdn")

def get_controller_ip():
    minion, grains = _get_controller()

    if minion is None:
        return None

    for iface, ips in grains["ip4_interfaces"].iteritems():
        if iface.startswith("tun"):
            continue
        for ip in ips:
            if IP(ip).iptype() == "PRIVATE" and ip != "127.0.0.1":
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
    for iface, ips in __grains__["ip4_interfaces"].iteritems():
        if iface.startswith("tun"):
            continue
        for ip in ips:
            if IP(ip).iptype() == "PRIVATE" and ip != "127.0.0.1":
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

def iface_info(iface):
    info = netifaces.ifaddresses(iface)
    info = info[netifaces.AF_INET][0]
    gws = netifaces.gateways()
    info["gateway"] = gws['default'][netifaces.AF_INET][0]

    return info

