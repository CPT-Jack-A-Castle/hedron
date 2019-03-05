# This whole file is really ugly and could be cleaned up a lot.

# Lock out "debian" account
hedron_users_lock_out_debian:
  user.present:
    - name: debian
    - password: '!'

# root password should be set at install time on some installs.
# This lets us lock out root or keep that password, as needed.
# VMs would probably want to be locked, workstation unlocked.
{% if 'hedron_root_password_locked' in grains %}
{% set lock_root = grains['hedron_root_password_locked'] %}
{% else %}
{% set lock_root = True %}
{% endif %}

{% if lock_root == True %}
hedron_users_lock_root:
  user.present:
    - name: root
    - password: '!'
{% endif %}

## Handle SSH keys installed by user who built the server. /root will become a tmpfs so this has to happen.
# FIXME: Rename to .host?
# NOTE: jinja in the .sls gets processed on the master. jinja in a templated file gets processed on the minion.
hedron_users_root_ssh_copy:
  file.managed:
    - name: /etc/ssh/authorized_keys.extra
    - mode: 0400
    - source: salt://hedron/users/files/admin_authorized_keys.extra.jinja
    - template: jinja
    - replace: False
##

# Since this is owned by root and only root can read it,
# may not work for non-root users.
# Changed to 444, mixed feelings on this.
hedron_users_authorized_keys:
  file.managed:
    - name: /etc/ssh/authorized_keys
    - mode: 0444
    - source: salt://hedron/users/files/admin_authorized_keys.jinja
    - template: jinja

hedron_users_make_user_group:
  group.present:
    - name: user
    - gid: 1984

# Pseudonym user called user.
# This is used in identity VMs and on the workstation.
hedron_users_make_user:
  user.present:
    - name: user
    - uid: 1984
    - gid: 1984
    - home: /home/user
    - createhome: False
    - shell: /bin/bash
    - groups:
      - audio

hedron_users_user_home_directory:
  file.directory:
    - name: /home/user
    - user: user
    - group: user
    - mode: 700

# Linux overrides folder permissions by default when mounting tmpfs??
# 0700 causes this to be ran over and over, 700 is what we need.
hedron_users_user_home_tmpfs:
  mount.mounted:
    - name: /home/user
    - device: tmpfs
    - fstype: tmpfs
    - opts: defaults,mode=700,uid=1984,gid=1984

# Mount /root as tmpfs so we don't write bash history to disk and such,
# possibly disclosing passwords or worse.
hedron_users_root_home_tmpfs:
  mount.mounted:
    - name: /root
    - device: tmpfs
    - fstype: tmpfs
    - opts: defaults,mode=700

# This... is a huge hack to let us use OpenVPN and tornet so we can utilize a clearnet exit.
hedron_users_openvpn_group:
  group.present:
    - name: openvpn
    - gid: 1194

hedron_users_openvpn:
  user.present:
    - name: openvpn
    - unique: False
    - uid: 0
    - gid: 1194
    - home: /root
    - createhome: False
    - shell: /bin/bash
