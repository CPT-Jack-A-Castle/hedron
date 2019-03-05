hedron_electron-cash_package_directory:
  file.directory:
    - name: /srv/electron-cash

hedron_electron-cash_package_archive:
  file.managed:
    - name: /var/tmp/electron-cash.tar.gz
    - source: https://electroncash.org/downloads/2.9.4/win-linux/Electron-Cash-2.9.4.tar.gz
    - source_hash: 70939028e5cf9401ab2fdf7cb760e58264cba260a4729128911fad6514ff15f9

hedron_electron-cash_package_extracted:
  cmd.wait:
    - name: tar -xzf /var/tmp/electron-cash.tar.gz -C /srv/electron-cash --strip-components=1
    - watch:
      - file: /var/tmp/electron-cash.tar.gz

