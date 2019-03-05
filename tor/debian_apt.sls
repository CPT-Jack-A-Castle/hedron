# For systems using tornet only!

# Another option is to install apt-tor-transport and use tor+http://.
# That's fine for a host but on a VM it results in requiring tor client
# for the 9050 socks port and has a double tor penalty.
hedron_tornet_debian_apt_config:
  file.managed:
    - name: /etc/apt/apt.conf.d/30letmeusetor
    - contents: 'Acquire::BlockDotOnion "false";'

##
# Seems to be the easiest method to do this, even though it's ugly.
# ftp.us.debian.org may not work in all cases? FIXME
hedron_tornet_debian_apt_ftp:
  file.replace:
    - name: /etc/apt/sources.list
    - pattern: ftp.us.debian.org
    - repl: vwakviie2ienjx6t.onion

hedron_tornet_debian_apt_security:
  file.replace:
    - name: /etc/apt/sources.list
    - pattern: security.debian.org
    - repl: sgvtcaew4bxjd7ln.onion
##
