# Key: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
hedron_node_repo:
  pkgrepo.managed:
    - name: deb https://deb.nodesource.com/node_12.x {{ grains['oscodename'] }} main
    - key_url: salt://hedron/node/files/node.asc

# This includes npm
hedron_node_install_package:
  pkg.installed:
    - name: nodejs
