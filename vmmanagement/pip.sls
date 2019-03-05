# pip dependencies for hedron.vmmanagement

include:
  - hedron.pip.python3
  - hedron.walkingliberty

# pip install systemd-python has extra requirements to build. This may be easier for now.
# python3-nacl is for paramiko to help make build easier. Otherwise needs python3-dev, most likely.
hedron_vmmanagement_pip_apt_packages:
  pkg.installed:
    - pkgs:
      - python3-systemd
      - python3-nacl

# bitcoinacceptor is for vmmanagement_create.py
hedron_vmmanagement_pip_dependencies:
  pip.installed:
    - pkgs:
      - paramiko
      - bitcoinacceptor
      - pytest
      - hug
      - requests
      - statsd
      - sshpubkeys
    - bin_env: /usr/bin/pip3
