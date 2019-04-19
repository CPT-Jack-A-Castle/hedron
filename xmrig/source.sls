hedron_xmrig_source_dependencies:
  pkg.installed:
    - pkgs:
      - build-essential
      - cmake
      - libuv1-dev
      - libmicrohttpd-dev
      - libssl-dev

hedron_xmrig_source_archive:
  file.managed:
    - name: /srv/salt/dist/xmrig.tar.gz
    - source:
      - salt://dist/xmrig.tar.gz
      - https://github.com/xmrig/xmrig/archive/v2.14.1.tar.gz
    - source_hash: 644168116cd76747c9e1358113598dd039cfac8fccd2b54f84b9d40a9b075c2b
    - makedirs: True
    - keep_source: False

hedron_xmrig_source_directory:
  file.directory:
    - name: /usr/local/src/xmrig

hedron_xmrig_source_extracted:
  cmd.run:
    - name: tar -xzf /srv/salt/dist/xmrig.tar.gz -C /usr/local/src/xmrig --strip-components=1  --owner 0 --group 0
    - creates: /usr/local/src/xmrig/README.md

hedron_xmrig_source_build_directory:
  file.directory:
    - name: /usr/local/src/xmrig/build

# If xmrig is running, the binary is in a state where it can't be overwritten.
hedron_xmrig_source_install:
  cmd.run:
    - name: cmake ..; make; cp xmrig /usr/local/bin/xmrig || true
    - cwd: /usr/local/src/xmrig/build
    - creates: /usr/local/bin/xmrig
