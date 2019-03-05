hedron_bash_bash_d:
  file.directory:
    - name: /etc/bash.d

hedron_base_bashrc:
  file.managed:
    - name: /etc/bash.bashrc
    - source: salt://hedron/base/files/bashrc.sh
