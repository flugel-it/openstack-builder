
{%- for img in pillar.glance.default_images if not img.get("disabled") %}

{%- set images = pillar.openstack.glance.get("images") %}

{%- if not images or img.slug in images %}

glance-download-{{ img.slug }}-image:
  file.managed:
    - name: /var/cache/openstack-builder/{{ img.slug }}
    - source: {{ img.url }}
    - source_hash: {{ img.hash_url }}
    - unless: glance image-list | grep "{{ img.name }}"

glance-create-{{ img.slug }}-image:
  cmd.run:
    - name: >
        glance image-create --name "{{ img.name }}"
        --file /var/cache/openstack-builder/{{ img.slug}} 
        --disk-format {{ img.format}} 
        --container-format {{ img.container_format }} 
        --is-public True
    - unless: glance image-list | grep "{{ img.name }}"
    - env:
      - OS_USERNAME: admin
      - OS_PASSWORD: {{ pillar.openstack.admin_pass }}
      - OS_TENANT_NAME: admin
      - OS_AUTH_URL: http://{{ salt.openstack.get_controller() }}:35357/v2.0
    - require:
      - file: glance-download-{{ img.slug }}-image

{%- endif %}
{%- endfor %}

