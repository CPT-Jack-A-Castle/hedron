hedron_ipfs_package_archive:
  file.managed:
    - name: /srv/salt/dist/ipfs.tar.gz
    - source:
      - salt://dist/ipfs.tar.gz
      - https://ipfs.io/ipns/dist.ipfs.io/go-ipfs/v0.4.20/go-ipfs_v0.4.20_linux-amd64.tar.gz
    - source_hash: 155dbdb2d7a9b8df38feccf48eb925cf9ab650754dc51994aa1e0bda1c1f9123
    - makedirs: True

hedron_ipfs_package_directory:
  file.directory:
    - name: /usr/local/ipfs
    - mode: 0755

hedron_ipfs_package_extracted:
  cmd.run:
    - name: tar --strip-components=1 --owner 0 --group 0 -xzf /srv/salt/dist/ipfs.tar.gz -C /usr/local/ipfs
    - creates: /usr/local/ipfs/ipfs

hedron_ipfs_package_symlink:
  file.symlink:
    - name: /usr/bin/ipfs
    - target: /usr/local/ipfs/ipfs
