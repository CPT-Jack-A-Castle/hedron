hedron_xmrig_package_archive:
  file.managed:
    - name: /srv/salt/dist/xmrig.tar.gz
    - source:
      - https://github.com/xmrig/xmrig/releases/download/v5.2.1/xmrig-5.2.1-xenial-x64.tar.gz
    - source_hash: b8ffbeb544fc00b93e47f280a972075f3b9215d9d76cda5a13ae3e0f38fb1b25
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
