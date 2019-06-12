# Remove the old one
hedron_saltstack_repo_absent:
  pkgrepo.absent:
    - name: deb http://repo.saltstack.com/apt/debian/9/amd64/archive/2018.3.3 stretch main
    - key_url: salt://hedron/saltstack/files/saltstack.asc

# Give us the new. PYTHON 3!!!! FINALLY!!
hedron_saltstack_repo:
  pkgrepo.managed:
    - name: deb http://repo.saltstack.com/py3/debian/9/amd64/2019.2 stretch main
    - key_url: salt://hedron/saltstack/files/saltstack.asc

# With the pinned repository, pkg.latest should be ideal.
hedron_saltstack_packages:
  pkg.latest:
    - pkgs:
      - salt-common
      - salt-ssh
