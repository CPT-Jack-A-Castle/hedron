include:
  - hedron.pip.python3
  - hedron.walkingliberty
  - hedron.sporestack
  - hedron.mega
  - hedron.nginx
  - hedron.ngircd.package
  - hedron.vmmanagement
  - hedron.httpmonitor.dependencies
  - hedron.tor
  - hedron.fiat_per_coin
  - hedron.settlers_of_cryptotan.package
  - hedron.dhcpd
  - hedron.saltstack
  - hedron.pasteit
  - hedron.keyplease

# nginx package is for nginx config testing.
# ngircd package is for testing ngircd config files
# dhcpd is for isc-dhcp-server is for checking dhcpd configuration files

# FIXME: Split this out between minimum to run and full blown testing.

hedron_develop_this_pip_dependencies_python3:
  pip.installed:
    - name: salt_dependencies_python3
    - requirements: salt://hedron/develop_this/files/requirements.txt
    - bin_env: /usr/bin/pip3

hedron_develop_this_packages:
  pkg.installed:
    - pkgs:
      - shellcheck       # Checking shell scripts.
