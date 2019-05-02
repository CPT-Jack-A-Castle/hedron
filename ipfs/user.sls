hedron_ipfs_user_group:
  group.present:
    - name: ipfs
    - gid: 942

hedron_ipfs_user_user:
  user.present:
    - name: ipfs
    - uid: 942
    - gid: 942
    - home: /srv/ipfs
    - createhome: False
    - shell: /bin/bash

hedron_ipfs_user_home:
  file.directory:
    - name: /srv/ipfs
    - user: ipfs
    - group: ipfs
    - mode: 0750
