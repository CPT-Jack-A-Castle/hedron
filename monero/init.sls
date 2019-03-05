{% set monero_version = "v0.11.1.0" %}

hedron_monero_fetch:
  file.managed:
    - name: /var/tmp/monero-{{ monero_version }}.tar.bz2
    - source: https://downloads.getmonero.org/cli/monero-linux-x64-{{ monero_version }}.tar.bz2
    - source_hash: 6581506f8a030d8d50b38744ba7144f2765c9028d18d990beb316e13655ab248

hedron_monero_directory:
  file.directory:
    - name: /var/tmp/monero

hedron_monero_extract:
  cmd.run:
    - name: tar --strip-components=2 -xjf /var/tmp/monero-{{ monero_version }}.tar.bz2 -C /var/tmp/monero
    - creates: /var/tmp/monero/monerod

hedron_monero_service_file:
  file.managed:
    - name: /etc/systemd/system/monero.service
    - source: salt://hedron/monero/files/monero.service

hedron_monero_user:
  user.present:
    - name: monero
    - gid_from_name: True
    - home: /home/monero
    - createhome: True
    - shell: /bin/false

# TODO: Won't restart if we upgrade the version.
hedron_monero_service_running:
  service.running:
    - name: monero
    - enable: True
