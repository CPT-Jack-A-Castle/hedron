# https://dankaminsky.com/2012/01/03/phidelius/
# Uses ld preload to give a deterministic /dev/random, /dev/urandom view of things.

hedron_phidelius_archive:
  file.managed:
    - name: /srv/salt/dist/phidelius.tar.gz
    - source:
      - salt://dist/phidelius.tar.gz
      - http://s3.amazonaws.com/dmk/phidelius-1.01.tgz
    - source_hash: 235975e7190ff276b412930885cb35dc921aac5262732b1341d8ee53244fe73f
    - makedirs: True

# archive.extracted is a bit of a mess...
# --group 0 is ideal for this but doesn't seem to work. Even with --no-same-owner, files get extracted with the "staff" group.
hedron_phidelius_extracted:
  archive.extracted:
    - name: /usr/local/src/phidelius
    - source: /srv/salt/dist/phidelius.tar.gz
    - options: '--strip-components=1 --no-same-owner'
    - enforce_toplevel: False

hedron_phidelius_build:
  cmd.run:
    - name: sh build.sh
    - cwd: /usr/local/src/phidelius
    - creates: /usr/local/src/phidelius/phidelius.so

hedron_phidelius_installed:
  cmd.run:
    - name: sh install.sh
    - cwd: /usr/local/src/phidelius
    - creates: /usr/local/bin/phidelius
