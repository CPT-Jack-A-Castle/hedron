openbox_package:
  pkg.installed:
    - name: openbox

# Provide our own locked down configuration without an ability to launch xterm or anything like that.
openbox_configuration:
  file.managed:
    - name: /etc/X11/openbox/rc.xml
    - source: salt://hedron/openbox/files/rc.xml
