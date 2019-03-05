electrum_is_alive:
  cmd.script:
    - name: salt://hedron/electrum/files/is-alive.sh
    - unless: /srv/electrum/electrum -D /run/electrum getaddressbalance 15Ghyee2Xyj8n9idpmsFv6ZkAWjotZcAoV
