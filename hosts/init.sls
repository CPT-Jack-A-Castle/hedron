{% if 'hedron.hosts' in pillar %}
{% for host in pillar['hedron.hosts'] %}

hedron_hosts_{{ host }}:
  host.present:
    - name: {{ host }}
    - ip: {{ pillar['hedron.hosts'][host] }}

{% endfor %}
{% endif %}
