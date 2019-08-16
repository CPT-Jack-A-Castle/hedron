hedron_rqlite_user_group:
  group.present:
    - name: rqlite
    - gid: 69

hedron_rqlite_user_user:
  user.present:
    - name: rqlite
    - uid: 69
    - gid: 69
    - shell: /bin/false
    - home: /var/lib/rqlited
    - createhome: False

hedron_rqlite_user_directory:
  file.directory:
    - name: /var/lib/rqlited
    - user: rqlite
    - group: rqlite
    - mode: 0700
