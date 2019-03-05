include:
  - hedron.pip.python3

hedron_httpmonitoring_dependencies:
  pip.installed:
    - pkgs:
      - requests
      - pysocks
    - bin_env: /usr/bin/pip3
