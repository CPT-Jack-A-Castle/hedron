hedron_fiat_per_coin_group:
  group.present:
    - name: fiat_per_coin
    - gid: 900

# Assuming this makes /var/cache/fiat_per_coin chmod 755.
hedron_fiat_per_coin_user:
  user.present:
    - name: fiat_per_coin
    - uid: 900
    - gid: 900
    - shell: /bin/false
    - home: /var/cache/fiat_per_coin
    - createhome: False

hedron_fiat_per_coin_directory:
  file.directory:
    - name: /var/cache/fiat_per_coin
    - user: fiat_per_coin
    - group: fiat_per_coin
    - mode: 0755

hedron_fiat_per_coin_service_file:
  file.managed:
    - name: /etc/systemd/system/fiat_per_coin@.service
    - contents: |
        [Unit]
        Description=fiat_per_coin update %I
        [Service]
        User=fiat_per_coin
        ProtectSystem=1
        Type=oneshot
        ExecStart=/usr/local/bin/fiat_per_coin update %I
        [Install]
        WantedBy=multi-user.target

hedron_fiat_per_coin_service_timer:
  file.managed:
    - name: /etc/systemd/system/fiat_per_coin@.timer
    - contents: |
        [Unit]
        Description=fiat_per_coin timer
        [Timer]
        OnCalendar=hourly
        RandomizedDelaySec=3600
        [Install]
        WantedBy=multi-user.target

{% for currency in ['btc', 'bch', 'bsv', 'xmr'] %}
hedron_fiat_per_coin_service_{{ currency }}_timer_running:
  service.running:
    - name: fiat_per_coin@{{ currency }}.timer
    - enable: True
    - watch:
      - file: /etc/systemd/system/fiat_per_coin@.timer
{% endfor %}

# This needs to be ran so we have data to work with as soon as possible.
# Sometimes the price APIs fail. We have some stub values, as of 2019-08-28
# that can be backups so we don't break an entire install.
hedron_fiat_per_coin_bch_prime:
  cmd.run:
    - name: systemctl start fiat_per_coin@bch || (echo 300 > /var/cache/fiat_per_coin/bch/even; echo 301 > /var/cache/fiat_per_coin/bch/odd)
    - creates:
      - /var/cache/fiat_per_coin/bch/even
      - /var/cache/fiat_per_coin/bch/odd

hedron_fiat_per_coin_btc_prime:
  cmd.run:
    - name: systemctl start fiat_per_coin@btc || (echo 10000 > /var/cache/fiat_per_coin/btc/even; echo 10001 > /var/cache/fiat_per_coin/btc/odd)
    - creates:
      - /var/cache/fiat_per_coin/btc/even
      - /var/cache/fiat_per_coin/btc/odd

hedron_fiat_per_coin_bsv_prime:
  cmd.run:
    - name: systemctl start fiat_per_coin@bsv || (echo 130 > /var/cache/fiat_per_coin/bsv/even; echo 131 > /var/cache/fiat_per_coin/bsv/odd)
    - creates:
      - /var/cache/fiat_per_coin/bsv/even
      - /var/cache/fiat_per_coin/bsv/odd

hedron_fiat_per_coin_xmr_prime:
  cmd.run:
    - name: systemctl start fiat_per_coin@xmr || (echo 77 > /var/cache/fiat_per_coin/xmr/even; echo 78 > /var/cache/fiat_per_coin/xmr/odd)
    - creates:
      - /var/cache/fiat_per_coin/xmr/even
      - /var/cache/fiat_per_coin/xmr/odd

# Verify things are working as they should be.
# Eventually, hopefully salt can actually test for creates arguments and except if they aren't made after the state is ran.
{% for currency in ['btc', 'bch', 'bsv', 'xmr'] %}
hedron_fiat_per_coin_{{ currency }}_exists:
  file.exists:
    - name: /var/cache/fiat_per_coin/{{ currency }}/even
{% endfor %}
