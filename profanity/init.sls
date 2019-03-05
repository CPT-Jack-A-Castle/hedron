# No Debian 9 package for it, so we build it ourselves.

hedron_profanity_dependencies:
  pkg.installed:
    - pkgs:
      - git
      - build-essential
      - automake
      - pkg-config
      - libtool
      - autoconf-archive
      - libexpat-dev
      - libstrophe-dev
      - libncursesw5-dev
      - libglib2.0-dev
      - libcurl3-dev
      - libreadline-dev
      - libotr5-dev

hedron_profanity_source:
  git.detached:
    - name: https://github.com/boothj5/profanity.git
    - target: /usr/local/src/profanity
    - rev: 0.5.1

hedron_profanity_install:
  cmd.run:
    - name: ./bootstrap.sh; ./configure --enable-otr; make; make install
    - cwd: /usr/local/src/profanity
    - creates: /usr/local/bin/profanity
