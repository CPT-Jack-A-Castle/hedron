# saltstack provides salt-ssh
include:
  - hedron.saltstack

hedron_vmmanagement_sporestackv2_salt:
  file.managed:
    - name: /usr/local/bin/sporestackv2_salt
    - source: salt://hedron/vmmanagement/files/sporestackv2_salt.sh
    - mode: 0755
