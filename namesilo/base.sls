include:
  - hedron.pip

# Dependency for new script.
# FIXME: Switch to pip or something if possible.
hedron_namesiren_base_dependency:
  file.managed:
    - name: /usr/local/lib/python3.5/dist-packages/namesilo.py
    - source: salt://hedron/namesilo/files/namesilo.py

hedron_namesiren_base_pip_dependencies:
  pip.installed:
    - name: aaargh
    - bin_env: /usr/bin/pip3

hedron_namesilo_base_namesiren:
  file.managed:
    - name: /usr/local/bin/namesiren
    - source: salt://hedron/namesilo/files/namesiren.py
    - mode: 0555
