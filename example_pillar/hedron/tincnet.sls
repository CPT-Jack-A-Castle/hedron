# This is very unusual for a few reasons. But, may be able to clean it up some day.
# Keep in mind that tinc does not support dashes in hostnames.
# If $HOST is foo-1, it will treat it as foo_1 automatically.
# Generating keys can be a little tricky. This can help:
# /usr/sbin/tincd -K; cat pub priv | sed 's/^/            /' ; rm pub priv
# AutoConnect = yes seems to be broken?
hedron.tincnet:
  red:
    subnet: 192.168.50.0/24
    conf: |
      Name = $HOST
      Mode = Switch
      ConnectTo = git
      Interface = rednettinc
      DeviceType = tap
      BindToAddress = 127.0.0.1 655
    hosts:
        git:
          internal_ip: 192.168.50.1/24
          public: |
            Address = 127.0.0.1 655
            -----BEGIN RSA PUBLIC KEY-----
            -----END RSA PUBLIC KEY-----
{% if grains['id'] == 'git' %}
          private: |
            -----BEGIN RSA PRIVATE KEY-----
            -----END RSA PRIVATE KEY-----
{% endif %}
        workstation-1:
          internal_ip: 192.168.50.10/24
          public: |
            -----BEGIN RSA PUBLIC KEY-----
            -----END RSA PUBLIC KEY-----
{% if grains['id'] == 'workstation-1' %}
          private: |
            -----BEGIN RSA PRIVATE KEY-----
            -----END RSA PRIVATE KEY-----
{% endif %}
  green:
    subnet: 192.168.51.0/24
    conf: |
      Name = $HOST
      Mode = Switch
      ConnectTo = git
      Interface = greennettinc
      DeviceType = tap
      BindToAddress = 127.0.0.1 656
    hosts:
        git:
          internal_ip: 192.168.51.1/24
          public: |
            Address = 127.0.0.1 656
            -----BEGIN RSA PUBLIC KEY-----
            -----END RSA PUBLIC KEY-----
{% if grains['id'] == 'git' %}
          private: |
            -----BEGIN RSA PRIVATE KEY-----
            -----END RSA PRIVATE KEY-----
{% endif %}
        workstation-1:
          internal_ip: 192.168.51.10/24
          public: |
            -----BEGIN RSA PUBLIC KEY-----
            -----END RSA PUBLIC KEY-----
{% if grains['id'] == 'workstation-1' %}
          private: |
            -----BEGIN RSA PRIVATE KEY-----
            -----END RSA PRIVATE KEY-----
{% endif %}
