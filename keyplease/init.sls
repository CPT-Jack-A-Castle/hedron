hedron_keyplease_installed:
  file.managed:
    - name: /usr/local/bin/keyplease
    - source: salt://hedron/keyplease/files/keyplease.sh
    - mode: 0755
