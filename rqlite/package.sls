hedron_rqlite_package_download:
  file.managed:
    - name: /var/tmp/rqlite.tar.gz
    - source: https://github.com/rqlite/rqlite/releases/download/v4.3.0/rqlite-v4.3.0-linux-amd64.tar.gz
    - source_hash: 75076780805077905764828b1274f9f841fdeb42b830f9d99c8e5517636e896d

hedron_rqlite_package_extract:
  cmd.run:
    - name: tar --strip-components 1 -xzf /var/tmp/rqlite.tar.gz -C /usr/local/bin/
    - creates:
      - /usr/local/bin/rqlite
      - /usr/local/bin/rqlited
