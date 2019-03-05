hedron_brainvault_brainkey_login_dependencies:
  pkg.installed:
    - pkgs:
      - suckless-tools # dmenu
      - xdotool

hedron_brainvault_brainkey_login_installed:
  file.managed:
    - name: /usr/local/bin/brainkey_login
    - source: salt://hedron/brainvault/files/brainkey_login.sh
    - mode: 0555
