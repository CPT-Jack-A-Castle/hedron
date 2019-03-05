# vanity .onion generator for Hidden Services V3

hedron_mkp224o_dependencies:
  pkg.installed:
    - pkgs:
      - git
      - autoconf
      - build-essential
      - libsodium-dev

hedron_mkp224o_source:
  git.latest:
    - name: https://github.com/cathugger/mkp224o.git
    - target: /usr/local/src/mkp224o
    - unless: test -d /usr/local/src/mkp224o

hedron_mkp224o_install:
  cmd.run:
    - name: "./autogen.sh; ./configure; make; mv mkp224o /usr/local/bin/"
    - creates: /usr/local/bin/mkp224o
    - cwd: /usr/local/src/mkp224o
