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



# -*- coding: utf-8 -*-
'''
    :codeauthor: Jeff Frost
    :copyright: © 2013 by the SaltStack Team, see AUTHORS for more details.
    :license: Apache 2.0, see LICENSE for more details.


    salt.grains.external_ip
    ~~~~~~~~~~~~~~~~~~~~~~~

    Return the external IP address reported by one of the following providers:

        * ipecho.net
        * ident.me

    Which ever reports a valid IP first
'''

# Import Python Libs
import contextlib
import socket
import urllib2

# Import salt libs
from salt.utils.validate.net import ipv4_addr as _ipv4_addr


def ext_ip():
    '''
    Return the external IP address
    '''
    check_ips = ('http://ipecho.net/plain',
                 'http://v4.ident.me')

    for url in check_ips:
        try:
            with contextlib.closing(urllib2.urlopen(url, timeout=3)) as req:
                ip_ = req.read().strip()
                if not _ipv4_addr(ip_):
                    continue
            return {'external_ip': ip_}
        except (urllib2.HTTPError,
                urllib2.URLError,
                socket.timeout):
            continue

    # Return an empty value as a last resort
    return {'external_ip': []}
