hedron_tor_base_apt_deps:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - python3-apt

# Key instructions: https://www.torproject.org/docs/debian.html.en
# Can also get it from /etc/apt/trusted.gpg.d/deb.torproject.org-keyring.gpg
# on an updated system. gpg --import, gpg -a --export, etc.
#
# oscodename is stretch, buster, etc.
hedron_tor_base_repo:
  pkgrepo.managed:
    - name: deb https://deb.torproject.org/torproject.org {{ grains['oscodename'] }} main
    - key_url: salt://hedron/tor/files/torproject.asc

hedron_tor_base_other_key_thing:
  pkg.installed:
    - name: deb.torproject.org-keyring

hedron_tor_base_install_packages:
  pkg.installed:
    - pkgs:
      - tor
      - torsocks

## Starting to learn a bit more about systemd and I think a lot of this is done this way for a reason.
## It's a pretty complex init setup but we should consider adopting it or something more like it in the future.

# Strange behaviors...
hedron_tor_base_stop_default_service:
  service.dead:
    - name: tor@default
    - enable: False

# Didn't realize you could have @thing files to override the @ behavior.
hedron_tor_base_remove_default_at_service_thing:
  file.absent:
    - name: /lib/systemd/system/tor@default.service

# I think this is this way for a reason.
hedron_tor_base_stop_other_default_service:
  cmd.run:
    - name: systemctl stop tor; systemctl disable tor; /etc/init.d/tor stop
    - onlyif: test -f /etc/init.d/tor

hedron_tor_base_delete_init_d_service_file:
  file.absent:
    - name: /etc/init.d/tor

hedron_tor_base_stop_another_possible_default_service:
  service.dead:
    - name: tor
    - enable: False

hedron_tor_base_delete_stock_service_file:
  file.absent:
    - name: /lib/systemd/system/tor.service

hedron_tor_base_directory_ownership:
  file.directory:
    - name: /etc/tor
    - user: debian-tor
    - group: debian-tor
    - mode: 0750

hedron_tor_base_service_file:
  file.managed:
    - name: /lib/systemd/system/tor@.service
    - source: salt://hedron/tor/files/tor@.service

# This is unused right now. Should consider adding it back in.
hedron_tor_base_include_directory:
  file.directory:
    - name: /etc/tor/include

hedron_tor_base_bridge_stub:
  file.managed:
    - name: /etc/tor/include/bridge
    - contents: '# Stub'
    - replace: False
