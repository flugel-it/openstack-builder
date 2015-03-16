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



{%- if salt.ps.swap_memory()['total'] == 0 %}

create-swap-file:
  cmd.run:
    - name: dd if=/dev/zero of=/.swap count=1000 bs=1M
    - unless: test -f /.swap

init-swap-file:
  cmd.run:
    - name: mkswap /.swap && touch /.swap.mkswap
    - unless: test -f /.swap.mkswap

/.swap:
  mount.swap
{%- endif %}

