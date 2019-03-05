# Users for runqemu slots.
# These are just stubs so we have gids for iptables and tornet

{% for slot in range(4000, 4060 + 1) %}
hedron_qemu_users_user_{{ slot }}_group:
  group.present:
    - name: slot{{ slot }}
    - gid: {{ slot }}
hedron_qemu_users_user_{{ slot }}:
  user.present:
    - name: slot{{ slot }}
    - uid: {{ slot }}
    - gid:  {{ slot }}
    - home: /var/empty
    - createhome: False
    - shell: /bin/false
{% endfor %}
