{% if grains['id'] == 'git' %}
hedron.tor_persistent_keys:
  hiddensshd_persistent: |
    -----BEGIN RSA PRIVATE KEY-----
    -----END RSA PRIVATE KEY-----
  hidden_service_wekan: |
    -----BEGIN RSA PRIVATE KEY-----
    -----END RSA PRIVATE KEY-----
{% endif %}
