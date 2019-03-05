include:
  - hedron.pip

hedron_tor_carml_dependencies:
  pkg.installed:
    - pkgs:
      - build-essential
      - python3-dev
      - libffi-dev
      - liblzma-dev

hedron_tor_carml_installed:
  pip.installed:
    - name: carml
    - bin_env: /usr/bin/pip3
