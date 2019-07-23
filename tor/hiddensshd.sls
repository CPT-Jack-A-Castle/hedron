# Just a hidden service for SSH access to the local machine.

# We run our own SSH daemon just for this with different host keys to help prevent fingerprinting.

include:
  - .persistent_keys
  - hedron.sshd.package

{% for algorithm in ['rsa', 'ecdsa', 'ed25519'] %}
hedron_tor_hiddensshd_generate_{{ algorithm }}_host_key:
  cmd.run:
    - name: ssh-keygen -f /etc/ssh/hiddenssh_host_{{ algorithm }}_key -N '' -t {{ algorithm }}
    - creates: /etc/ssh/hiddenssh_host_{{ algorithm }}_key
{% endfor %}

hedron_tor_hiddensshd_config:
  file.managed:
    - name: /etc/ssh/hiddensshd_config
    - template: jinja
    - source: salt://hedron/tor/files/hiddensshd_config.jinja
    - mode: 0400

hedron_tor_hiddensshd_service_file:
  file.managed:
    - name: /etc/systemd/system/hiddensshd.service
    - source: salt://hedron/tor/files/hiddensshd.service
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_tor_hiddensshd_service_running:
  service.running:
    - name: hiddensshd
    - enable: True

hedron_tor_hiddensshd_torrc:
  file.managed:
    - name: /etc/tor/hiddensshd.torrc
    - source: salt://hedron/tor/files/hiddensshd.torrc.jinja
    - template: jinja

hedron_tor_hiddensshd_tor_running:
  service.running:
    - name: tor@hiddensshd
    - enable: True
    - watch:
      - file: /etc/tor/hiddensshd.torrc

{% if 'hedron.tor_persistent_keys' in pillar %}

{% if 'hiddensshd_persistent' in pillar['hedron.tor_persistent_keys'] %}

hedron_tor_hiddensshd_persistent_torrc:
  file.managed:
    - name: /etc/tor/hiddensshd_persistent.torrc
    - source: salt://hedron/tor/files/hiddensshd_persistent.torrc.jinja
    - template: jinja

hedron_tor_hiddensshd_persistent_tor_running:
  service.running:
    - name: tor@hiddensshd_persistent
    - enable: True
    - watch:
      - file: /etc/tor/hiddensshd_persistent.torrc

{% endif %}

{% endif %}

{% if 'hedron.tor_persistent_keys_v3' in pillar %}

{% if 'hiddensshd_persistent_v3' in pillar['hedron.tor_persistent_keys_v3'] %}

hedron_tor_hiddensshd_persistent_v3_torrc:
  file.managed:
    - name: /etc/tor/hiddensshd_persistent_v3.torrc
    - source: salt://hedron/tor/files/hiddensshd_persistent_v3.torrc.jinja
    - template: jinja

hedron_tor_hiddensshd_persistent_tor_v3_running:
  service.running:
    - name: tor@hiddensshd_persistent_v3
    - enable: True
    - watch:
      - file: /etc/tor/hiddensshd_persistent_v3.torrc

{% endif %}

{% endif %}

