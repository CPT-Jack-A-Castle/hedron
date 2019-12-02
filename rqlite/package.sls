hedron_rqlite_package_download:
  file.managed:
    - name: /srv/salt/dist/rqlite.tar.gz
    - source: https://github.com/rqlite/rqlite/releases/download/v4.6.0/rqlite-v4.6.0-linux-amd64.tar.gz
    - source_hash: ed84c7957bbe571ee0898942b698661eb1c5b8e308b98b4d034ad07fc667b111
    - makedirs: True

hedron_rqlite_package_extract:
  cmd.run:
    - name: tar --strip-components 1 -xzf /srv/salt/dist/rqlite.tar.gz -C /usr/local/bin/
    - creates:
      - /usr/local/bin/rqlite
      - /usr/local/bin/rqlited
