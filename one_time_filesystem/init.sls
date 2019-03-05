include:
  - hedron.gocryptfs

# This state is designed so that it can be called before base.

# Makes a filesystem "one time use" by encrypting the used directories.
# This is for helping hide important disk contents from prying eyes, but the server will not come back after a reboot.
# This state is ideally ran first, or done manually with a script. salt-ssh will "taint" the disk, however it will likely be overwritten.
# But potentially important information may touch the disk momentarily. May or may not be a concern for you.

hedron_one_time_filesystem_dependenices:
  pkg.installed:
    - pkgs:
      - pwgen
      - rsync

hedron_one_time_filesystem_fuse_conf:
  file.managed:
    - name: /etc/fuse.conf
    - source: salt://hedron/one_time_filesystem/files/fuse.conf

# Consider /snap eventually? Not using it yet. Will need to make it first or maybe install a snap package.
# /usr is going into D state, so /usr/local instead. This does reveal what we have installed our stuff
# should be going into /usr/local.
{% for directory in ['/etc', '/home', '/var', '/usr/local', '/srv', '/opt'] %}
hedron_one_time_filesystem_{{ directory }}:
  cmd.script:
    - name: salt://hedron/one_time_filesystem/files/encrypt_dir.sh
    - unless: 'mount | grep "{{ directory }}_encrypted_work on {{ directory }} type fuse.gocryptfs"'
    - args: {{ directory }}
{% endfor %}

# For /tmp, /root, we should delete everything there before going tmpfs.
# Also consider adding a zeroing step to fill up the disk with zeroes to erase deleted files properly.
# But probably not an issue.
