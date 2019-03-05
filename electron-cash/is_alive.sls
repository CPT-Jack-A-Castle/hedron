electron-cash_is_alive:
  cmd.script:
    - name: salt://hedron/electron-cash/files/is-alive.sh
    - unless: /srv/electron-cash/electron-cash -D /run/electron-cash getaddressbalance 15Ghyee2Xyj8n9idpmsFv6ZkAWjotZcAoV
