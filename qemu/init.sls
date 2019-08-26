# TODO: Consider breaking this up for workstations and headless servers.

include:
  - .bridge_networking
  - .runqemu_py
  - .users
  - hedron.vmmanagement.user
  - .ipxe
  - hedron.ipxe_scripts
  - hedron.vmmanagement

hedron_qemu_packages:
  pkg.installed:
    - pkgs:
      - picocom
      - qemu-kvm
      - qemu-utils
      - ssvnc
      - arptables
      - ebtables

hedron_qemu_vncviewer_systemd:
  file.managed:
    - name: /etc/systemd/system/vncviewer@.service
    - mode: 0400
    - source: salt://hedron/qemu/files/vncviewer@.service

hedron_qemu_runqemu_systemd:
  file.managed:
    - name: /etc/systemd/system/runqemu@.service
    - mode: 0400
    - source: salt://hedron/qemu/files/runqemu@.service

hedron_qemu_runqemu_start_systemd:
  file.managed:
    - name: /etc/systemd/system/runqemu_start@.service
    - mode: 0400
    - source: salt://hedron/qemu/files/runqemu_start@.service

hedron_qemu_runqemu_stop_systemd:
  file.managed:
    - name: /etc/systemd/system/runqemu_stop@.service
    - mode: 0400
    - source: salt://hedron/qemu/files/runqemu_stop@.service

# Enable nested KVM -- primarily for testing the ISOs.
hedron_qemu_nested_kvm:
  file.managed:
    - name: /etc/modprobe.d/kvm-intel.conf
    - contents: 'options kvm-intel nested=1'

# FIXME: Hacky, maybe insecure.
# qemu package doesn't create /etc/qemu. Hence the makedirs
hedron_qemu_bridge_config:
  file.managed:
    - name: /etc/qemu/bridge.conf
    - contents: |
        allow rednet
        allow greennet
        allow clearnetexitbr
        allow primary
    - makedirs: True

hedron_qemu_runqemu_directory:
  file.directory:
    - name: /var/tmp/runqemu
    - mode: 0750
    - user: root
    - group: vmmanagement

hedron_qemu_ifup_script:
  file.managed:
    - name: /etc/qemu-ifup
    - mode: 0700
    - source: salt://hedron/qemu/files/qemu-ifup.sh

hedron_qemu_ifdown_script:
  file.managed:
    - name: /etc/qemu-ifdown
    - mode: 0700
    - source: salt://hedron/qemu/files/qemu-ifdown.sh

hedron_qemu_vmmanagement_interface:
  file.managed:
    - name: /usr/local/sbin/vmmanagement_interface
    - mode: 0700
    - source: salt://hedron/qemu/files/vmmanagement_interface.py
