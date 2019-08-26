# Normally this would just be "stretch", which would break the minion_id set in salt-call --local

# Not using FQDN, at least for now.
{% set minion_id = grains['id'].split('.')[0] %}

# This may be more realtime and have more effect down the road.
hedron_base_hostname_set:
  cmd.run:
    - name: hostnamectl set-hostname {{ minion_id }}
    - unless: hostname | grep '^{{ minion_id }}$'

hedron_base_hostname_salt_minion_id:
  file.managed:
    - name: /etc/salt/minion_id
    - contents: {{ minion_id }}
    - makedirs: True

hedron_base_hostname_localhost:
  host.present:
    - name: localhost
    - ip:
      - 127.0.0.1
      - ::1

# Ugly, can be improved
# This is important for installing the collectd package.
{% if 'hedron.hosts' in pillar %}
{% if minion_id not in pillar['hedron.hosts'] %}
hedron_base_hostname_minion_id:
  host.present:
    - name: {{ minion_id }}
    - ip: 127.0.1.1
{% endif %}
{% else %}
hedron_base_hostname_minion_id:
  host.present:
    - name: {{ minion_id }}
    - ip: 127.0.1.1
{% endif %}
