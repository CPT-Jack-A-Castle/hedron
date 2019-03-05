# Kinda silly, but we do this so that we already have Python 3.
include:
  - hedron.pip

# FIXME: Should we be linking to python3 which is also a symlink or just to 3.5?
hedron_python3default_symlink:
  file.managed:
    - name: /usr/bin/python
    - target: /usr/bin/python3.5

# This is questionable...
hedron_python3default_symlink_pip:
  file.managed:
    - name: /usr/bin/pip
    - target: /usr/bin/pip3
