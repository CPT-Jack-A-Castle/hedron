# We run our own SSH daemon to minimize correlations and provide a very specific behavior of allowing a passwordless user for SSH.
# We use SSH because it's encrypted both for clearnet use and for tor, of course tor already provides its own encryption.
# Also, it can be easier to use without libraries in some ways which may be a problem in onion land, at least for some time.
# Of course we will provide client libraries to enable automation.
# Onion garden only works with extreme automation. Without it, it cannot work. Servers have to be disposible for a hostile environment.
# This is used by runqemu to dogfood the APIs and avoid writing duplicate code.

include:
  - hedron.sshd.package

{% for algorithm in ['rsa', 'ecdsa', 'ed25519'] %}
hedron_vmmanagement_sshd_generate_{{ algorithm }}_host_key:
  cmd.run:
    - name: ssh-keygen -f /etc/ssh/vmmanagement_host_{{ algorithm }}_key -N '' -t {{ algorithm }}
    - creates: /etc/ssh/vmmanagement_host_{{ algorithm }}_key
    - umask: 0077
{% endfor %}

hedron_vmmanagement_sshd_config:
  file.managed:
    - name: /etc/ssh/vmmanagement_config
    - source: salt://hedron/vmmanagement/files/vmmanagement_sshd_config
    - mode: 0400

# FIXME: Redundant with tor/hiddensshd. Can easily be service@config type.
hedron_vmmanagement_sshd_service_file:
  file.managed:
    - name: /etc/systemd/system/vmmanagement_sshd.service
    - source: salt://hedron/vmmanagement/files/vmmanagement_sshd.service

hedron_vmmanagement_sshd_service_running:
  service.running:
    - name: vmmanagement_sshd
    - enable: True
    - watch:
      - file: /etc/systemd/system/vmmanagement_sshd.service
      - file: /etc/ssh/vmmanagement_config
