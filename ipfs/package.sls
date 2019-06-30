hedron_ipfs_package_archive:
  file.managed:
    - name: /srv/files/decensor/assets/a7ec5ddc4d52f818cbf3853a80f7ec17f9fde9128f039485dbe1889cf673d562
    - source:
      - /srv/files/decensor/assets/a7ec5ddc4d52f818cbf3853a80f7ec17f9fde9128f039485dbe1889cf673d562
      - https://dist.ipfs.io/go-ipfs/v0.4.21/go-ipfs_v0.4.21_linux-amd64.tar.gz
    - source_hash: a7ec5ddc4d52f818cbf3853a80f7ec17f9fde9128f039485dbe1889cf673d562
    - makedirs: True
    - replace: False

hedron_ipfs_package_directory:
  file.directory:
    - name: /usr/local/ipfs
    - mode: 0755

hedron_ipfs_package_extracted:
  cmd.run:
    - name: tar --strip-components=1 --owner 0 --group 0 -xzf /srv/files/decensor/assets/a7ec5ddc4d52f818cbf3853a80f7ec17f9fde9128f039485dbe1889cf673d562 -C /usr/local/ipfs
    - creates: /usr/local/ipfs/ipfs

hedron_ipfs_package_symlink:
  file.symlink:
    - name: /usr/bin/ipfs
    - target: /usr/local/ipfs/ipfs
