hedron_gincoin_dependencies:
  pkg.installed:
    - pkgs:
      - build-essential
      - automake
      - pkg-config
      - git
      - libtool
      - libdb++-dev
      - libboost-all-dev
      - libevent-dev

hedron_gincoin_git_latest:
  git.latest:
    - name: https://github.com/GIN-coin/gincoin-core
    - target: /usr/local/src/gincoin
    - unless: test -d /usr/local/src/gincoin

hedron_gincoin_package_install:
  cmd.script:
    - name: salt://hedron/gincoin/files/build.sh
    - cwd: /usr/local/src/gincoin
    - creates: /usr/local/bin/gincoind
