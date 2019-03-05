# Always generate the latest sample config.
hedron_ravd_config_sample:
  file.managed:
    - name: /etc/radvd.conf.sample
    - source: salt://hedron/radvd/files/radvd.conf.jinja
    - template: jinja

# FIXME: Can we do this with file.copy?
# Don't overwrite the config that's there.
hedron_ravd_config:
  file.managed:
    - name: /etc/radvd.conf
    - source: salt://hedron/radvd/files/radvd.conf.jinja
    - template: jinja
    - replace: False
