hedron.rqlited.auth:
  - username: admin
    password: admin_password
    perms:
      - all
  - username: query
    password: query_password
    perms:
      - query

# https://github.com/rqlite/rqlite/issues/570
{% if grains['id'] == 'node-1' %}
hedron.rqlited.options: -auth /etc/rqlited/auth.json -http-addr 10.10.0.1:4001 -raft-addr 10.10.0.1:4002
{% elif grains['id'] == 'node-2' %}
hedron.rqlited.options: -auth /etc/rqlited/auth.json -http-addr 10.10.0.2:4001 -raft-addr 10.10.0.2:4002 -join http://admin:admin_password@10.10.0.1,http://admin:admin_password@10.10.0.3
{% elif grains['id'] == 'node-3' %}
hedron.rqlited.options: -auth /etc/rqlited/auth.json -http-addr 10.10.0.3:4001 -raft-addr 10.10.0.3:4002 -join http://admin:admin_password@10.10.0.1,http://admin:admin_password@10.10.0.2
{% endif %}
