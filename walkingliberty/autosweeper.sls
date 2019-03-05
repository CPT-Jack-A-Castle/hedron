hedron_walkingliberty_autosweeper_script:
  file.managed:
    - name: /usr/local/sbin/autosweeper
    - source: salt://hedron/walkingliberty/files/autosweeper.py
    - mode: 0755

hedron_walkingliberty_autosweeper_config:
  file.managed:
    - name: /etc/walkingliberty/autosweeper.json
    - source: salt://hedron/walkingliberty/files/autosweeper.json.jinja
    - template: jinja
    - user: root
    - mode: 0400

hedron_walkingliberty_autosweeper_service:
  file.managed:
    - name: /etc/systemd/system/autosweeper.service
    - contents: |
        [Unit]
        Description=Sweeps funds into an upstream wallet.
        [Service]
        Type=oneshot
        TimeoutSec=120
        ExecStart=/usr/local/sbin/autosweeper

hedron_walkingliberty_autosweeper_service_timer:
  file.managed:
    - name: /etc/systemd/system/autosweeper.timer
    - contents: |
        [Unit]
        Description=Sweeps funds into an upstream wallet daily.
        [Timer]
        OnCalendar=daily
        [Install]
        WantedBy=multi-user.target

hedron_walkingliberty_autosweeper_service_timer_enabled:
  service.running:
    - name: autosweeper.timer
    - enable: True
