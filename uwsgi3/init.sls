include:
  - hedron.pip.python3

hedron_uwsgi3_dependencies:
  pkg.installed:
    - pkgs:
      - build-essential
      - python3-dev

hedron_uwsgi3_install:
  pip.installed:
    - name: uwsgi
    - bin_env: /usr/bin/pip3
