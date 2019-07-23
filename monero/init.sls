# https://repo.getmonero.org/monero-project/monero-site/issues/964
# Download is bz2 but actually gzip :-/
hedron_monero_fetch:
  file.managed:
    - name: /srv/salt/dist/monero.tar.gz
    - source: https://dlsrc.getmonero.org/cli/monero-linux-x64-v0.14.1.0.tar.bz2
    - source_hash: 2b95118f53d98d542a85f8732b84ba13b3cd20517ccb40332b0edd0ddf4f8c62

hedron_monero_directory:
  file.directory:
    - name: /usr/local/monero

# Won't extract if we upgrade the version.
hedron_monero_extract:
  cmd.run:
    - name: tar --strip-components=1 -xzf /srv/salt/dist/monero.tar.gz -C /usr/local/monero
    - creates: /usr/local/monero/monerod

hedron_monero_service_file:
  file.managed:
    - name: /etc/systemd/system/monero.service
    - source: salt://hedron/monero/files/monero.service

hedron_monero_group:
  group.present:
    - name: monero

hedron_monero_user:
  user.present:
    - name: monero
    - gid_from_name: True
    - home: /home/monero
    - createhome: True
    - shell: /bin/false

# Won't restart if we upgrade the version.
hedron_monero_service_running:
  service.running:
    - name: monero
    - enable: True
    - watch:
      - file: /etc/systemd/system/monero.service
