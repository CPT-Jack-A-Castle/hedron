## This is for tracking the time until soft/hard disables and expiration.
hedron_sporestack_liferemaining_script:
  file.managed:
    - name: /usr/local/bin/liferemaining
    - mode: 0755
    - source: salt://hedron/sporestack/files/liferemaining.sh
