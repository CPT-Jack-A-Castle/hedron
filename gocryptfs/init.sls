hedron_gocrypfs_dependencies:
  pkg.installed:
    - name: fuse

# 1.7 has a bug with one_time_filesystem: https://github.com/rfjakob/gocryptfs/issues/427
hedron_gocryptfs_file:
  file.managed:
    - name: /srv/salt/dist/gocryptfs.tar.gz
    - source:
      - salt://dist/gocryptfs.tar.gz
      - https://github.com/rfjakob/gocryptfs/releases/download/v1.6.1/gocryptfs_v1.6.1_linux-static_amd64.tar.gz
    - source_hash: d6306b1b14e78733908b37c71ec28146e8f7d7cbbc979b132a3aa61c49696601
    - makedirs: True

hedron_gocryptfs_extracted:
  archive.extracted:
    - name: /var/tmp/gocryptfs
    - source: /srv/salt/dist/gocryptfs.tar.gz
    - enforce_toplevel: False

hedron_gocryptfs_binary_installed:
  file.copy:
    - name: /usr/local/bin/gocryptfs
    - source: /var/tmp/gocryptfs/gocryptfs

hedron_gocryptfs_man_page_installed:
  file.copy:
    - name: /usr/local/share/man/man1/gocryptfs.1
    - source: /var/tmp/gocryptfs/gocryptfs.1
    - makedirs: True
