include:
  - hedron.ipxe
  - hedron.pip.python3

hedron_qemu_ipxe_runqemu_create:
  file.managed:
    - name: /usr/local/sbin/runqemu_create
    - source: salt://hedron/qemu/files/runqemu_create.sh
    - mode: 0500

hedron_qemu_sshwait_dependencies:
  pip.installed:
    - name: paramiko
    - bin_env: /usr/bin/pip3

# Currently only used in the source path by sporestack-stretch.sh
hedron_qemu_sshwait_installed:
  file.managed:
    - name: /usr/local/bin/sshwait
    - source: salt://hedron/qemu/files/sshwait.py
    - mode: 0555

hedron_qemu_ipxe_build_iso_script:
  file.managed:
    - name: /usr/local/bin/ipxe_iso
    - mode: 755
    - source: salt://hedron/qemu/files/ipxe_iso.sh

