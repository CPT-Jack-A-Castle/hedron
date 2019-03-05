# Won't take effect this boot but that's probably not an issue.
# Does not work with the default kernel behavior of renaming network interfaces.
hedron_baremetal_extras_wifi_powersaving_disabled:
  file.managed:
    - name: /lib/udev/rules.d/70-wifi-powersave.rules
    - contents: ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="/sbin/iw dev %k set power_save off"
