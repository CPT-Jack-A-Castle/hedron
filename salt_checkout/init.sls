hedron_salt_checkout_directory:
  file.directory:
    - name: /srv/salt
    - mode: 0700

# Unfortunately, can't just do salt://.
# There's so much hackery going on here...

# FIXME: Doesn't really clean ever possible thing, if say a folder is deleted.
# show_changes: False is for saltstack/salt issue #47042
# Also not a bad idea to keep around in general.
# FIXME: filemode_keep broken in saltstack 2018-03, so set everything to executable :-/
{% for dir in pillar['hedron.all_dirs'] %}
hedron_salt_checkout_sync_{{ dir }}:
   file.recurse:
    - name: /srv/salt/{{ dir }}
    - source: salt://{{ dir }}
    - include_empty: True
    - clean: True
    - file_mode: '0755'
    - show_changes: False
    - exclude_pat: '*/.git/*'
{% endfor %}

hedron_salt_checkout_sync_top_sls:
  file.managed:
    - name: /srv/salt/top.sls
    - source: salt://top.sls
