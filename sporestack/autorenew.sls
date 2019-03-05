# TODO: Port to systemd service and timer. May not need `at`.

include:
  - hedron.sporestack
  - hedron.walkingliberty

hedron_sporestack_autorenew_atd:
  pkg.installed:
    - name: at

hedron_sporestack_autorenew_bip32:
  file.managed:
    - name: /var/tmp/autorenew_bip32
    - contents_pillar: hedron.walkingliberty
    - mode: 0400

# Outside of default PATH so it doesn't accidentally get called.
hedron_sporestack_autorenew_script:
  file.managed:
    - name: /var/tmp/autorenew
    - source: salt://hedron/sporestack/files/renew.sh
    - mode: 0500

# FIXME: This is very flakey.
hedron_sporestack_first_autorenew:
  cmd.run:
    - name: /var/tmp/autorenew
    - unless: 'atq | grep root'
