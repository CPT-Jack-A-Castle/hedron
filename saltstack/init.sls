# Sets the upstream saltstack repository so we can have newer versions.
hedron_saltstack_repo:
  pkgrepo.managed:
    - name: deb http://repo.saltstack.com/apt/debian/9/amd64/archive/2018.3.3 stretch main
    - key_url: salt://hedron/saltstack/files/saltstack.asc

# With the pinned repository, pkg.latest should be ideal.
hedron_saltstack_packages:
  pkg.latest:
    - pkgs:
      - salt-common
      - salt-ssh
