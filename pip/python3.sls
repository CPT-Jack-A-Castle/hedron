include:
  - .python2

# Including python2 is for a salt quirk.

hedron_pip_python3_packages:
  pkg.installed:
    - pkgs:
      - python3-pip
      - python3-setuptools
      - python3-wheel

# This is to help us work with Python 3.5 or 3.7.

hedron_pip_python3_dir:
  file.directory:
    - name: /usr/local/lib/python3

hedron_pip_python3_dist_dir:
  file.directory:
    - name: /usr/local/lib/python3/dist-packages
