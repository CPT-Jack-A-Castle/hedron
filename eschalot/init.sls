# vanity .onion generator.

hedron_eschalot_dependencies:
  pkg.installed:
    - pkgs:
      - git
      - libssl-dev
      - build-essential

hedron_eschalot_source:
  git.latest:
    - name: https://github.com/ReclaimYourPrivacy/eschalot.git
    - target: /var/tmp/eschalot
    - unless: test -d /var/tmp/eschalot

hedron_eschalot_install:
  cmd.run:
    - name: "make install"
    - creates: /usr/local/bin/eschalot
    - cwd: /var/tmp/eschalot
