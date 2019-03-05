include:
  - .python2

# Including python2 is for a salt quirk.

hedron_pip_python3_packages:
  pkg.installed:
    - pkgs:
      - python3-pip
      - python3-setuptools
      - python3-wheel
