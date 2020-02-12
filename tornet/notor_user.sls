# notor user's group
hedron_tornet_notor_user_group:
  group.present:
    - name: notor
    - gid: 1986

# notor user.
hedron_tornet_notor_user:
  user.present:
    - name: notor
    - uid: 1986
    - gid: 1986
    - home: /var/empty
    - createhome: False
    - shell: /bin/bash
