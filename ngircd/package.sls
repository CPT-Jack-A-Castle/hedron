# Work around Debian's run service on install issue:

hedron_ngircd_package_installed:
  cmd.run:
    - name: apt-get install -y ngircd; rm /etc/init.d/ngircd; systemctl disable ngircd; systemctl stop ngircd
    - creates: /usr/sbin/ngircd
