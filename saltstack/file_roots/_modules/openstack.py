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
        return get_public_ip()

def get_controller_ip():
    minion, grains = _get_controller()

    if minion is None:
        return None

    return _get_ip("private", grains)

def has_role(role):
    return role in __grains__.get("roles", [])

def get_public_ip():
    return _get_ip("public", __grains__)

def get_private_ip():
    return _get_ip("private", __grains__)

def _get_ip(network, grains):
    try:
        net = __pillar__["networks"][network]
    except KeyError:
        gateways = netifaces.gateways()
        default_iface = gateways["default"][netifaces.AF_INET][1]
        for iface, ips in grains["ip4_interfaces"].iteritems():
            if iface == default_iface:
                return ips[0]

        return None

    for iface, ips in grains["ip4_interfaces"].iteritems():
        if iface == "lo":
            continue
        for ip in ips:
            if IP(net).overlaps(ip):
                return ip

    return False

def external_iface():
    try:
        return __pillar__["openstack"]["external_iface"]
    except KeyError:
        raise Exception("Pillar openstack.external_iface required.")

def iface_info(iface):
    info = netifaces.ifaddresses(iface)
    info = info[netifaces.AF_INET][0]
    gws = netifaces.gateways()
    info["gateway"] = gws['default'][netifaces.AF_INET][0]

    return info

