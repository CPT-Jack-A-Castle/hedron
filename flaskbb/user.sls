hedron_flaskbb_group:
  group.present:
    - name: flaskbb
    - gid: 942

hedron_flaskbb_user:
  user.present:
    - name: flaskbb
    - uid: 942
    - gid: 942
    - home: /srv/flaskbb
    - createhome: False
    - shell: /bin/false

hedron_flaskbb_home:
  file.directory:
    - name: /srv/flaskbb
    - mode: 0700
    - user: flaskbb
    - group: flaskbb
