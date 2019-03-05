include:
  - hedron.pip.python3
  - hedron.hedronpy

# Salt has a bug/behavior where pip.installed requires pip from python 2, even if we use the pip3 bin_env.
hedron_runqemu_py_dependencies:
  pip.installed:
    - pkgs:
      - aaargh
      - sh
    - bin_env: /usr/bin/pip3

hedron_runqemu_py_installed:
  file.managed:
    - name: /usr/local/sbin/runqemu_py
    - source: salt://hedron/qemu/files/runqemu_py.py
    - mode: 0500

hedron_runqemu_py_destroy_expired_service:
  file.managed:
    - name: /etc/systemd/system/runqemu_py_destroy_expired.service
    - contents: |
        [Unit]
        Description=Destroy expired VMs
        [Service]
        Type=oneshot
        TimeoutSec=300
        ExecStart=/usr/local/sbin/runqemu_py destroy_expired_virtual_machines

hedron_runqemu_py_destroy_expired_timer:
  file.managed:
    - name: /etc/systemd/system/runqemu_py_destroy_expired.timer
    - contents: |
        [Unit]
        Description=Destroy expired VMs timer.
        [Timer]
        OnCalendar=minutely
        [Install]
        WantedBy=multi-user.target

hedron_runqemu_py_enable_timer:
  service.running:
    - name: runqemu_py_destroy_expired.timer
    - enable: True


hedron_hedron_py_vmmanagemnt_run_installed:
  file.managed:
    - name: /usr/local/sbin/vmmanagement_run
    - source: salt://hedron/qemu/files/vmmanagement_run.py
    - mode: 0500
