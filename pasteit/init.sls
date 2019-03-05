# Generic "pastebin" utility featuring multiple backends for redundancy.

hedron_pasteit_installed:
  file.managed:
    - name: /usr/local/bin/pasteit
    - source: salt://hedron/pasteit/files/pasteit.sh
    - mode: 0755
