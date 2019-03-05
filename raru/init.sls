# run as random user
# Cheap user level isolation.

hedron_raru_dependenices:
  pkg.installed:
    - pkgs:
      - build-essential

hedron_raru_source_archive:
  file.managed:
    - name: /srv/salt/dist/raru.tar.gz
    - source:
      - salt://dist/raru.tar.gz
      - https://github.com/teran-mckinney/raru/archive/e7605f4b8b58125ae6be6d904f3a379cd2262799.tar.gz
    - source_hash: eac410f691bafe0b015c6f936ff5c49335df8b738ccf6ae49d77cbcf1bcc7643
    - makedirs: True
    - keep_source: False

hedron_raru_source_directory:
  file.directory:
    - name: /usr/local/src/raru

hedron_raru_source_extracted:
  cmd.run:
    - name: tar -xzf /srv/salt/dist/raru.tar.gz -C /usr/local/src/raru --strip-components=1
    - creates: /usr/local/src/raru/Makefile

hedron_raru_install:
  cmd.run:
    - name: make install
    - cwd: /usr/local/src/raru
    - creates: /usr/local/bin/raru

hedron_raru_johndoe_install:
  file.managed:
    - name: /usr/local/bin/johndoe
    - mode: 0555
    - source: salt://hedron/raru/files/johndoe.sh
