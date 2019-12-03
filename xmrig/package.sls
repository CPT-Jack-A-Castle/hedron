hedron_xmrig_package_archive:
  file.managed:
    - name: /srv/salt/dist/xmrig.tar.gz
    - source:
      - https://github.com/xmrig/xmrig/releases/download/v5.1.0/xmrig-5.1.0-xenial-x64.tar.gz
    - source_hash: 536aac41864f0078849fea8dad039efac9fb6234d60554aa751991d802117625
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
