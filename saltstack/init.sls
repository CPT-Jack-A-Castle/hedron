# Going to try installing it from pip now.

# No buster version yet.

hedron_saltstack_repo:
  pkgrepo.managed:
    - name: deb http://repo.saltstack.com/py3/debian/9/amd64/2019.2 stretch main
    - key_url: salt://hedron/saltstack/files/saltstack.asc

# With the pinned repository, pkg.latest should be ideal.
# Although it's slower and they haven't updated it. Going back to installed for now.
hedron_saltstack_packages:
  pkg.installed:
    - pkgs:
      - salt-common
      - salt-ssh

# This seems like it will work, but installing on the workstation is tricky because it needs autoconf and compiler stuff to build pycrypto and all.
#include:
#  - hedron.pip

# This includes salt-ssh
#hedron_saltstack_pip_installed:
#  pip.installed:
#    - name: salt==2019.2.0
#    - bin_env: /usr/bin/pip3
