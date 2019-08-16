hedron_ipfs_package_archive:
  file.managed:
    - name: /srv/salt/dist/ipfs.tar.gz
    - source:
      - https://github.com/ipfs/go-ipfs/releases/download/v0.4.22/go-ipfs_v0.4.22_linux-amd64.tar.gz
    - source_hash: 43431bbef105b1c8d0679350d6f496b934d005df28c13280a67f0c88054976aa
    - makedirs: True
    - replace: False

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
