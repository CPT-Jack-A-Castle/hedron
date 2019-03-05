# Ugly to put this here but not certain of the best place for it.
hedron_notbit_user_group:
  group.present:
    - name: notbit
    - gid: 68

hedron_notbit_user_user:
  user.present:
    - name: notbit
    - uid: 68
    - gid: 68
    - shell: /bin/false
    - home: /var/lib/notbit
    - createhome: False

hedron_notbit_user_directory:
  file.directory:
    - name: /var/lib/notbit
    - user: notbit
    - group: notbit
    - mode: 0770
