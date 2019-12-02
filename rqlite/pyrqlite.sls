include:
  - hedron.pip.python3
  - .package

# No direct pip installable for this.
# FIXME: They have no release tag. Latest master as of 2018-05-15
hedron_rqlite_pyrqlite_archive:
  file.managed:
    - name: /srv/salt/dist/pyrqlite.tar.gz
    - source:
      - https://github.com/rqlite/pyrqlite/archive/7bc124f29fd094ab16af465317748298c04d8494.tar.gz
    - source_hash: 61884c2b4c6713439f969d8c57512bdf0eedcc391f810dc9433ffd2e4089810e
    - makedirs: True

hedron_rqlite_pyrqlite_src_directory:
  file.directory:
    - name: /usr/local/src/pyrqlite

# setup.py install somehow started only doing .eggs which breaks with --no-site.
hedron_rqlite_pyrqlite_extract_and_install:
  cmd.run:
    - name: tar -xzf /srv/salt/dist/pyrqlite.tar.gz --strip-components=1; pip3 install .
    - cwd: /usr/local/src/pyrqlite
    - creates: {{ grains['hedron.python.dist.path'] }}/pyrqlite/__init__.py
