hedron_xmrig_package_archive:
  file.managed:
    - name: /srv/salt/dist/xmrig.tar.gz
    - source:
      - https://github.com/xmrig/xmrig/releases/download/v5.0.1/xmrig-5.0.1-xenial-x64.tar.gz
    - source_hash: aa34890738a3494de2fa0e44db346937fea7339852f5f10b5d4655f95e2d8f1f
    - makedirs: True

hedron_xmrig_package_directory:
  file.directory:
    - name: /var/tmp/xmrig

hedron_xmrig_package_extracted:
  cmd.run:
    - name: tar -xzf /srv/salt/dist/xmrig.tar.gz -C /var/tmp/xmrig --strip-components=1 --owner 0 --group 0
    - creates: /var/tmp/xmrig/xmrig

hedron_xmrig_package_installed:
  file.managed:
    - name: /usr/local/bin/xmrig
    - source: /var/tmp/xmrig/xmrig
    - mode: 0755
