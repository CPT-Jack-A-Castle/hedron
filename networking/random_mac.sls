# systemd can do random MACs for us!
# Won't take effect until reboot, but likely not an issue.
# Works everywhere tested except Zero's Linksys USB ethernet.
hedron_baremetal_random_mac:
  file.managed:
    - name: /lib/systemd/network/99-default.link
    - source: salt://hedron/networking/files/99-default.link
