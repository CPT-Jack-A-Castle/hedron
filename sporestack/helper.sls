include:
  - hedron.ipxe_scripts
  - hedron.keyplease

hedron_sporestack_helper:
  file.managed:
    - name: /usr/local/bin/sporestack_helper
    - source: salt://hedron/sporestack/files/sporestack_helper.sh
    - mode: 0755
