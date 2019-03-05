hedron_xmrig_package_dependencies:
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
      - https://github.com/xmrig/xmrig/archive/v2.8.3.tar.gz
    - source_hash: ddf0c273fcf71889989c971c2a27b81a05aa2352a4bc03481730576583de4696
    - makedirs: True
    - keep_source: False

hedron_xmrig_source_directory:
  file.directory:
    - name: /usr/local/src/xmrig

hedron_xmrig_source_extracted:
  cmd.run:
    - name: tar -xzf /srv/salt/dist/xmrig.tar.gz -C /usr/local/src/xmrig --strip-components=1
    - creates: /usr/local/src/xmrig/README.md

hedron_xmrig_package_build_directory:
  file.directory:
    - name: /usr/local/src/xmrig/build

# If xmrig is running, the binary is in a state where it can't be overwritten.
hedron_xmrig_package_install:
  cmd.run:
    - name: cmake ..; make; cp xmrig /usr/local/bin/xmrig || true
    - cwd: /usr/local/src/xmrig/build
    - creates: /usr/local/bin/xmrig
