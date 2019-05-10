# file.comment seems completely broken.

#hedron_base_disable_swap_persistent:
#  file.comment:
#    - name: /etc/fstab
#    - regex: swap

hedron_base_disable_swap_persistent:
  cmd.run:
    - name: sed -i /swap/d /etc/fstab
    - onlyif: grep swap /etc/fstab

hedron_base_disable_swap_now:
  cmd.wait:
    - name: swapoff -a
    - watch:
      - cmd: sed -i /swap/d /etc/fstab
