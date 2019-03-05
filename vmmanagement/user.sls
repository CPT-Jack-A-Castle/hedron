hedron_vmmanagement_user_group:
  group.present:
    - name: vmmanagement
    - gid: 1060

hedron_vmmanagement_user:
  user.present:
    - name: vmmanagement
    - uid: 1060
    - gid: 1060
    - home: /home/vmmanagement
    - createhome: False
    - empty_password: True
    - shell: /usr/local/bin/vmmanagement_shell

# The above does not work as intended. Creates a locked account. So, we do this.
hedron_vmmanagement_blank_password:
  cmd.run:
    - name: passwd -d vmmanagement
    - unless: 'passwd -S vmmanagement | grep NP'

# This one is not tmpfs'ed. We do add authorized_keys to this one.
hedron_vmmanagement_user_home_directory:
  file.directory:
    - name: /home/vmmanagement
    - user: root
    - group: vmmanagement
    - mode: 0730
