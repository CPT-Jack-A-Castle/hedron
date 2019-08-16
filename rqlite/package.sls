hedron_rqlite_package_download:
  file.managed:
    - name: /srv/salt/dist/rqlite.tar.gz
    - source: https://github.com/rqlite/rqlite/releases/download/v4.5.0/rqlite-v4.5.0-linux-amd64.tar.gz
    - source_hash: 8f98a2720f15b23474dcd1128a7032a3c4dd76a070cf74f75d45ba17800d9df6
    - makedirs: True

hedron_rqlite_package_extract:
  cmd.run:
    - name: tar --strip-components 1 -xzf /srv/salt/dist/rqlite.tar.gz -C /usr/local/bin/
    - creates:
      - /usr/local/bin/rqlite
      - /usr/local/bin/rqlited
