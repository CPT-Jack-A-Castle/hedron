hedron_electrum_directory:
  file.directory:
    - name: /srv/electrum

hedron_electrum_archive:
  file.managed:
    - name: /var/tmp/electrum.tar.gz
    - source: https://download.electrum.org/3.0.2/Electrum-3.0.2.tar.gz
    - source_hash: 4dff75bc5f496f03ad7acbe33f7cec301955ef592b0276f2c518e94e47284f53

hedron_electrum_extracted:
  cmd.wait:
    - name: tar -xzf /var/tmp/electrum.tar.gz -C /srv/electrum --strip-components=1
    - watch:
      - file: /var/tmp/electrum.tar.gz
