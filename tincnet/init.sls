include:
  - hedron.tinc


# tinc does not support dashes in hostnames, only underscores and automatically converts dashes to underscores.
{% set tinc_hostname = grains['id'].replace('-', '_') %}

{% if 'hedron.tincnet' in pillar %}

{% for net in pillar['hedron.tincnet'] %}

hedron_tincnet_{{ net }}_configuration_file:
  file.managed:
    - name: /etc/tinc/{{ net }}/tinc.conf
    - contents_pillar: hedron.tincnet:{{ net }}:conf
    - makedirs: True

hedron_tincnet_{{ net }}_hosts_directory:
  file.directory:
    - name: /etc/tinc/{{ net }}/hosts
    - mode: 0700

{% for host in pillar['hedron.tincnet'][net]['hosts'] %}
hedron_tincnet_{{ net }}_hosts_{{ host }}:
  file.managed:
    - name: /etc/tinc/{{ net }}/hosts/{{ host }}
    - contents_pillar: hedron.tincnet:{{ net }}:hosts:{{ host }}:public
{% endfor %}

hedron_tincnet_{{ net }}_private_key:
  file.managed:
    - name: /etc/tinc/{{ net }}/rsa_key.priv
    - contents_pillar: hedron.tincnet:{{ net }}:hosts:{{ tinc_hostname }}:private
    - mode: 0400

hedron_tincnet_{{ net }}_up_script:
  file.managed:
    - name: /etc/tinc/{{ net }}/tinc-up
    - mode: 0700
{%- if tinc_hostname in pillar['hedron.tincnet'][net]['hosts'] %}
    - contents: 'brctl addbr {{ net }}net; brctl addif {{ net }}net $INTERFACE; ip l s {{ net }}net up; ip l s $INTERFACE up; ip a a {{ pillar['hedron.tincnet'][net]['hosts'][tinc_hostname]['internal_ip'] or 'NONE' }} dev {{ net }}net'
{%- else %}
    - contents: 'brctl addbr {{ net }}net; brctl addif {{ net }}net $INTERFACE; ip l s {{ net }}net up; ip l s $INTERFACE up'
{%- endif %}

hedron_tincnet_{{ net }}_down_script:
  file.managed:
    - name: /etc/tinc/{{ net }}/tinc-down
    - mode: 0500
    - contents: 'ip l s $INTERFACE down; ip l s {{ net }}net down; brctl delbr {{ net }}net'

hedron_tincnet_{{ net }}_service:
  service.running:
    - name: tinc@{{ net }}
    - enable: True
    - watch:
      - file: /etc/tinc/{{ net }}/tinc.conf

{% if tinc_hostname in pillar['hedron.tincnet'][net]['hosts'] %}
{% if 'zone_ip' in pillar['hedron.tincnet'][net]['hosts'][tinc_hostname] %}
hedron_tincnet_{{ net }}_zone_ip_file:
  file.managed:
    - name: /etc/{{ net }}_zone_ip
    - contents_pillar: hedron.tincnet:{{ net }}:hosts:{{ tinc_hostname }}:zone_ip
    - mode: 0400
{% endif %}
{% endif %}

{% endfor %}

{% endif %}
