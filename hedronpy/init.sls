# Be sure we have Python 3
include:
  - hedron.pip.python3

hedron_hedronpy_dependencies:
  pip.installed:
    - name: statsd
    - bin_env: /usr/bin/pip3

hedron_hedronpy_installed:
  file.managed:
    - name: /usr/local/lib/python3.5/dist-packages/hedron.py
    - source: salt://hedron/hedronpy/files/hedron.py
