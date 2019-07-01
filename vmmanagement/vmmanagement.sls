include:
  - hedron.walkingliberty
  - hedron.hedronpy
  - hedron.file_helper

# walkingliberty needs to come before the vmmanagement.json

hedron_vmmanagement_vmmanagement_package_dependencies:
  pkg.installed:
    - pkgs:
      - socat

hedron_vmmanagement_vmmanagement_override_code:
  cmd.run:
    - name: pwgen -s 20 1 | file_helper write_file_from_stdin --exactly_bytes 21 /etc/vmmanagement.override_code
    - creates: /etc/vmmanagement.override_code
    - umask: 0077

# Always generate the latest sample config.
hedron_vmmanagement_vmmanagement_config_sample:
  file.managed:
    - name: /etc/vmmanagement.json.sample
    - source: salt://hedron/vmmanagement/files/vmmanagement.json.jinja
    - template: jinja
    - user: root
    - mode: 0400

# Hack to make sure vmmanagement configuration sample is valid json
hedron_vmmanagement_vmmanagement_config_sample_validate:
  cmd.run:
    - name: python3 -m json.tool /etc/vmmanagement.json.sample
    - unless: python3 -m json.tool /etc/vmmanagement.json.sample

# FIXME: Can we do this with file.copy?
# Don't overwrite the config that's there.
hedron_vmmanagement_vmmanagement_config:
  file.managed:
    - name: /etc/vmmanagement.json
    - source: salt://hedron/vmmanagement/files/vmmanagement.json.jinja
    - replace: False
    - template: jinja
    - user: root
    - group: vmmanagement
    - mode: 0640

hedron_vmmanagement_vmmanagement_creation_directory:
  file.directory:
    - name: /var/tmp/vmmanagement_creation
    - user: root
    - group: vmmanagement
    - mode: 0770

hedron_vmmanagement_vmmanagement_topup_directory:
  file.directory:
    - name: /var/tmp/vmmanagement_topup
    - user: root
    - group: vmmanagement
    - mode: 0730

hedron_vmmanagement_vmmanagement_shell:
  file.managed:
    - name: /usr/local/bin/vmmanagement_shell
    - source: salt://hedron/vmmanagement/files/vmmanagement_shell.sh
    - mode: 0755


hedron_vmmanagement_vmmanagement_create_library:
  file.managed:
    - name: /usr/local/lib/python3.5/dist-packages/vmmanagement_create.py
    - source: salt://hedron/vmmanagement/files/vmmanagement_create.py
    - mode: 0644

hedron_vmmanagement_vmmanagement_create:
  file.managed:
    - name: /usr/local/bin/vmmanagement_create
    - source: salt://hedron/vmmanagement/files/vmmanagement_create.py
    - mode: 0755

hedron_vmmanagement_vmmanagement_run_create:
  file.managed:
    - name: /usr/local/sbin/vmmanagement_run_create
    - source: salt://hedron/vmmanagement/files/vmmanagement_run_create.py
    - mode: 0755

hedron_vmmanagement_vmmanagement_run_create_service:
  file.managed:
    - name: /etc/systemd/system/vmmanagement_run_create.service
    - source: salt://hedron/vmmanagement/files/vmmanagement_run_create.service

hedron_vmmanagement_vmmanagement_run_create_path_service:
  file.managed:
    - name: /etc/systemd/system/vmmanagement_run_create.path
    - source: salt://hedron/vmmanagement/files/vmmanagement_run_create.path

hedron_vmmanagement_vmmangement_run_create_path_enable_service:
  service.running:
    - name: vmmanagement_run_create.path
    - enable: True

hedron_vmmanagement_vmmanagement_topup:
  file.managed:
    - name: /usr/local/bin/vmmanagement_topup
    - source: salt://hedron/vmmanagement/files/vmmanagement_topup.py
    - mode: 0755

hedron_vmmanagement_vmmanagement_run_topup:
  file.managed:
    - name: /usr/local/sbin/vmmanagement_run_topup
    - source: salt://hedron/vmmanagement/files/vmmanagement_run_topup.py
    - mode: 0755

hedron_vmmanagement_vmmanagement_run_topup_service:
  file.managed:
    - name: /etc/systemd/system/vmmanagement_run_topup.service
    - source: salt://hedron/vmmanagement/files/vmmanagement_run_topup.service

hedron_vmmanagement_vmmanagement_run_topup_path_service:
  file.managed:
    - name: /etc/systemd/system/vmmanagement_run_topup.path
    - source: salt://hedron/vmmanagement/files/vmmanagement_run_topup.path

hedron_vmmanagement_vmmangement_run_topup_path_enable_service:
  service.running:
    - name: vmmanagement_run_topup.path
    - enable: True

hedron_vmmanagement_vmmanagement_host_info:
  file.managed:
    - name: /usr/local/bin/vmmanagement_host_info
    - source: salt://hedron/vmmanagement/files/vmmanagement_host_info.py
    - mode: 0755
