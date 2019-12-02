hedron_monero_package_fetch:
  file.managed:
    - name: /srv/salt/dist/monero.tar.bz2
    - source: https://downloads.getmonero.org/cli/monero-linux-x64-v0.15.0.1.tar.bz2
    - source_hash: 8d61f992a7e2dbc3d753470b4928b5bb9134ea14cf6f2973ba11d1600c0ce9ad

hedron_monero_package_directory:
  file.directory:
    - name: /usr/local/monero

# Unfortunately, won't extract if we upgrade the version.
hedron_monero_package_extract:
  cmd.run:
    - name: tar --strip-components=1 -xjf /srv/salt/dist/monero.tar.bz2 -C /usr/local/monero
    - creates: /usr/local/monero/monerod
