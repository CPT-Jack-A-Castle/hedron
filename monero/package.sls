# Actually gzip even though .bz2 extension. Should be fixed next release?
# https://repo.getmonero.org/monero-project/monero-site/issues/964
hedron_monero_package_fetch:
  file.managed:
    - name: /srv/salt/dist/monero.tar.gz
    - source: https://dlsrc.getmonero.org/cli/monero-linux-x64-v0.14.1.2.tar.bz2
    - source_hash: a4d1ddb9a6f36fcb985a3c07101756f544a5c9f797edd0885dab4a9de27a6228

hedron_monero_package_directory:
  file.directory:
    - name: /usr/local/monero

# Unfortunately, won't extract if we upgrade the version.
hedron_monero_package_extract:
  cmd.run:
    - name: tar --strip-components=1 -xzf /srv/salt/dist/monero.tar.gz -C /usr/local/monero
    - creates: /usr/local/monero/monerod
