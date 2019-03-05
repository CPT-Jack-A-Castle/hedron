hedron_flaskbb_package_dependencies:
  pkg.installed:
    - pkgs:
      - git
      - python
      - python-setuptools

hedron_flaskbb_package_source:
  git.detached:
    - name: https://github.com/flaskbb/flaskbb.git
    - rev: 510af6ff2d907a0cf6b57a21f64a9c1c0682e051
    - target: /usr/local/src/flaskbb
    - unless: test -f /usr/local/src/flaskbb/wsgi.py

hedron_flaskbb_package_configuration_file:
  file.managed:
    - name: /usr/local/src/flaskbb/flaskbb.cfg
    - source:
        - salt://flaskbb/files/flaskbb.cfg
        - salt://hedron/flaskbb/files/flaskbb.cfg

hedron_flaskbb_package_logs_directory:
  file.directory:
    - name: /srv/flaskbb/logs
    - user: flaskbb
    - group: flaskbb

# Need to run make install in /usr/local/src/flaskbb. It prompts for questions.
hedron_flaskbb_package_install:
  file.exists:
    - name: /usr/local/bin/flaskbb
