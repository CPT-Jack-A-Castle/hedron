# Package installation generally generates these for us.

{% for algorithm in ['rsa', 'ecdsa', 'ed25519'] %}
hedron_sshd_service_generate_{{ algorithm }}_host_key:
  cmd.run:
    - name: ssh-keygen -f /etc/ssh/ssh_host_{{ algorithm }}_key -N '' -t {{ algorithm }}
    - creates: /etc/ssh/ssh_host_{{ algorithm }}_key
    - umask: 0077
{% endfor %}

hedron_sshd_service_opensshd_config:
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://hedron/sshd/files/sshd_config
    - mode: 0400

hedron_sshd_service_opensshd_service:
  service.running:
    - name: sshd
    - enable: True
    - watch:
      - file: /etc/ssh/sshd_config
