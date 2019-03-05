include:
  - hedron.walkingliberty
  - hedron.ssh-keydgen
  - hedron.pip.python3
  - hedron.hedronpy
  - hedron.mega
  - hedron.fiat_per_coin # For brainvault-banner.sh
  - .brainkey_login

hedron_pgpwordify:
  file.managed:
    - name: /usr/local/lib/python3.5/dist-packages/pgpwordify.py
    - source: salt://hedron/brainvault/files/pgpwordify.py

#hedron_brainvault_package_dependencies:
#  pkg.installed:
#    - pkgs:
#      - fakeroot  # Lets us use ssh-keygen without it blowing up from getuid() failing.

hedron_brainvault_pip_dependencies:
  pip.installed:
    - pkgs:
      - aaargh
      - cryptography
      - sh
      - argon2_cffi
    - bin_env: /usr/bin/pip3

hedron_brainvault_brainkey_executable:
  file.managed:
    - name: /usr/local/bin/brainkey
    - source: salt://hedron/brainvault/files/brainkey.py
    - mode: 0555

hedron_brainvault_brainkey_library:
  file.managed:
    - name: /usr/local/lib/python3.5/dist-packages/brainkey.py
    - source: salt://hedron/brainvault/files/brainkey.py

# Where the brainvault-persistence backups get stored.
# Only let root list directory contents. 0733 is very deliberate.
# Execute bit lets you access inside but not list. Read is for listing.
hedron_brainvault_persistence_directory:
  file.directory:
    - name: /var/tmp/brainvault-persistence
    - mode: 0733

hedron_brainvault_persistence_py_executable:
  file.managed:
    - name: /usr/local/bin/brainvault_persistence_py
    - source: salt://hedron/brainvault/files/brainvault_persistence.py
    - mode: 0555

hedron_brainvault_persistence_executable:
  file.managed:
    - name: /usr/local/bin/brainvault-persistence
    - source: salt://hedron/brainvault/files/brainvault-persistence.sh
    - mode: 0555

hedron_brainvault_ssh_executable:
  file.managed:
    - name: /usr/local/bin/brainvault-ssh
    - source: salt://hedron/brainvault/files/brainvault-ssh.sh
    - mode: 0555

# Disabled since notbit is too unstable for this use.
hedron_brainvault_bitmessage_executable:
  file.managed:
    - name: /usr/local/bin/brainvault-bitmessage
    - source: salt://hedron/brainvault/files/brainvault-bitmessage.sh
    - mode: 0444

hedron_brainvault_statusbar:
  file.managed:
    - name: /usr/local/bin/brainvault_dwm_statusbar
    - source: salt://hedron/brainvault/files/brainvault_dwm_statusbar.sh
    - mode: 0555

hedron_brainvault_skel_executable:
  file.managed:
    - name: /usr/local/bin/brainvault-skel
    - source: salt://hedron/brainvault/files/brainvault-skel.sh
    - mode: 0555

hedron_brainvault_banner_executable:
  file.managed:
    - name: /usr/local/bin/brainvault-banner
    - source: salt://hedron/brainvault/files/brainvault-banner.sh
    - mode: 0555

hedron_brainvault_executable:
  file.managed:
    - name: /usr/local/bin/brainvault
    - source: salt://hedron/brainvault/files/brainvault.sh
    - mode: 0555
