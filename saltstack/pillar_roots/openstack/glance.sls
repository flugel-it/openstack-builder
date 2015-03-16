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




glance:
  default_images:
    - slug: ubuntu-14.04
      name: Ubuntu 14.04 Trusty 64-bit
      url: http://cloud-master.flugel.it/images/trusty-server-cloudimg-amd64.qcow2
      hash_url: http://cloud-master.flugel.it/images/trusty-server-cloudimg-amd64.qcow2.md5
      format: qcow2
      container_format: bare
    - slug: centos-7
      name: CentOS 7 64-bit
      url: http://cloud-master.flugel.it/images/CentOS-7-x86_64-GenericCloud-20140929_01.qcow2
      hash_url: http://cloud-master.flugel.it/images/CentOS-7-x86_64-GenericCloud-20140929_01.qcow2.md5
      format: qcow2
      container_format: bare
    - slug: fedora-21
      name: Fedora 21 64-bit
      url: http://cloud-master.flugel.it/images/Fedora-Cloud-Atomic-20141203-21.x86_64.qcow2
      hash_url: http://cloud-master.flugel.it/images/Fedora-Cloud-Atomic-20141203-21.x86_64.qcow2.md5
      format: qcow2
      container_format: bare
    - slug: debian-jessie
      name: Debian 8 Jessie 64-bit
      url: http://cloud-master.flugel.it/images/debian-testing-openstack-amd64.qcow2
      hash_url: http://cloud-master.flugel.it/images/debian-testing-openstack-amd64.qcow2.md5
      format: qcow2
      container_format: bare
    - slug: opensuse-13.2
      name: OpenSUSE 13.2 64-bit
      url: http://cloud-master.flugel.it/images/openSUSE_13.2_Server.x86_64-0.0.1.qcow2
      hash_url: http://cloud-master.flugel.it/images/openSUSE_13.2_Server.x86_64-0.0.1.qcow2.md5
      format: qcow2
      container_format: bare
    - slug: windows-2012r2
      disabled: true
      name: Windows Server 2012 r2
      url: http://cloud-master.flugel.it/images/windows_server_2012_r2_standard_eval_kvm_20140607.qcow2.gz
      hash_url: http://cloud-master.flugel.it/images/windows_server_2012_r2_standard_eval_kvm_20140607.qcow2.gz.md5
      format: qcow2
      container_format: bare

