include:
  - .dependencies

hedron_remaster_create_iso:
  cmd.script:
    - name: salt://hedron/remaster/files/remaster.sh
    - creates: /var/tmp/hedron.iso
