# FIXME: Switch to Python 3

# gstreamer1.0 is probably way more than we need.
# Those gstreamer packages are needed for audio. Audio only works for the "xpra" user so there's more to fix on this.
hedron_xpra_apt_deps:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - python-apt
      - python3-apt
#      - python-gst-1.0
#      - python3-gst-1.0
#      - pulseaudio
#      - gstreamer1.0

hedron_xpra_repository:
  pkgrepo.managed:
    - name: deb https://xpra.org/ {{ grains['oscodename'] }} main
    - key_url: salt://hedron/xpra/files/xpra.asc

hedron_xpra_package:
  pkg.installed:
    - name: xpra
    - version: 2.2.1-r17715-1

# May need to manually kill with systemctl
# This does indeed kill it but I think it may have to be ran twice to do that?
hedron_xpra_kill_default_service:
  service.dead:
    - name: xpra
    - enable: False

# In case xpra doesn't list them properly
hedron_xpra_extra_dependencies:
  pkg.installed:
    - pkgs:
      - python-dbus
      - dbus-x11
