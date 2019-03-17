hedron_ipfs_archive:
  file.managed:
    - name: /srv/salt/dist/ipfs.tar.gz
    - source:
      - salt://dist/ipfs.tar.gz
      - https://ipfs.io/ipns/dist.ipfs.io/go-ipfs/v0.4.19/go-ipfs_v0.4.19_linux-amd64.tar.gz
    - source_hash: e35c2067e70d2f165f909d1b70f4eb2a2151528f1741a5927494d54c313b6012
    - makedirs: True
    - keep_source: False

hedron_ipfs_directory:
  file.directory:
    - name: /usr/local/ipfs
    - mode: 0755

hedron_ipfs_extracted:
  cmd.run:
    - name: tar --strip-components=1 --owner 0 --group 0 -xzf /srv/salt/dist/ipfs.tar.gz -C /usr/local/ipfs
    - creates: /usr/local/ipfs/ipfs

hedron_ipfs_symlink:
  file.symlink:
    - name: /usr/bin/ipfs
    - target: /usr/local/ipfs/ipfs
