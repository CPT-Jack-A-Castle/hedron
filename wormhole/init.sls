include:
  - hedron.pip.python3

hedron_wormhole_package_dependencies:
  pkg.installed:
    - name: python3-dev

# pip name is magic-wormhole, but installs as wormhole
hedron_wormhole_pip_installed:
  pip.installed:
    - name: magic-wormhole
    - bin_env: /usr/bin/pip3
