hedron_xmrig_package_archive:
  file.managed:
    - name: /srv/salt/dist/xmrig.tar.gz
    - source:
      - salt://dist/xmrig-built.tar.gz
      - https://github.com/xmrig/xmrig/releases/download/v2.14.1/xmrig-2.14.1-xenial-x64.tar.gz
    - source_hash: b48dda017b9332a26d0d13ec912c360c3965292731d7eb3a9bfe441caae08bb3
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
