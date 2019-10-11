# oscodename is stretch, buster, etc.
# osmajorrelease is 9, 10, etc.
#hedron_saltstack_repo:
#  pkgrepo.managed:
#    - name: deb http://repo.saltstack.com/py3/debian/{{ grains['osmajorrelease'] }}/amd64/2019.2 {{ grains['oscodename'] }} main
#    - key_url: salt://hedron/saltstack/files/saltstack.asc

# Saltstack broke their mirror: https://github.com/saltstack/salt/issues/54951
hedron_saltstack_repo_absent:
  pkgrepo.absent:
    - name: deb http://repo.saltstack.com/py3/debian/{{ grains['osmajorrelease'] }}/amd64/2019.2 {{ grains['oscodename'] }} main

hedron_saltstack_repo:
  pkgrepo.managed:
    - name: deb http://repo.saltstack.com/py3/debian/{{ grains['osmajorrelease'] }}/amd64/archive/2019.2.1 {{ grains['oscodename'] }} main
    - key_url: salt://hedron/saltstack/files/saltstack.asc

# With the pinned repository, pkg.latest should be ideal but it's much slower.
hedron_saltstack_packages:
  pkg.installed:
    - pkgs:
      - salt-common
      - salt-ssh

# This seems like it can work, but installing on the workstation is tricky because it needs autoconf and compiler stuff to build pycrypto and all.
#include:
#  - hedron.pip

# This includes salt-ssh
#hedron_saltstack_pip_installed:
#  pip.installed:
#    - name: salt==2019.2.0
#    - bin_env: /usr/bin/pip3
