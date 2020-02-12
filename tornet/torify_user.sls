# torify user's group
hedron_tornet_torify_user_group:
  group.present:
    - name: torify
    - gid: 1985

# torify user.
hedron_tornet_torify_user:
  user.present:
    - name: torify
    - uid: 1985
    - gid: 1985
    - home: /var/empty
    - createhome: False
    - shell: /bin/bash
