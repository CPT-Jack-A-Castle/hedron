hedron_rclone_dependencies:
  pkg.installed:
    - name: unzip

hedron_rclone_extracted:
  archive.extracted:
    - name: /var/tmp/rclone
    - source: https://github.com/ncw/rclone/releases/download/v1.42/rclone-v1.42-linux-amd64.zip
    - source_hash: 7a623f60a5995f33cca3ed285210d8701c830f6f34d4dc50d74d75edd6a5bfa6

# This may not work when upgrading, not certain.
hedron_rclone_installed:
  file.copy:
    - name: /usr/local/bin/rclone
    - source: /var/tmp/rclone/rclone-v1.42-linux-amd64/rclone
    - mode: 0555
