include:
  - hedron.pip.python3

hedron_file_helper_pip_dependency:
  pip.installed:
    - name: aaargh
    - bin_env: /usr/bin/pip3

hedron_file_helper_installed:
  file.managed:
    - name: /usr/local/bin/file_helper
    - source: salt://hedron/file_helper/files/file_helper.py
    - mode: 0555
