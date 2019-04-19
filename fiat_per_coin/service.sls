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
        Description=fiat_per_coin on the 55th minute of every hour
        [Timer]
        OnCalendar=*:55
        [Install]
        WantedBy=multi-user.target

hedron_fiat_per_coin_service_btc_timer_running:
  service.running:
    - name: fiat_per_coin@btc.timer
    - enable: True

hedron_fiat_per_coin_service_bch_timer_running:
  service.running:
    - name: fiat_per_coin@bch.timer
    - enable: True

hedron_fiat_per_coin_service_bsv_timer_running:
  service.running:
    - name: fiat_per_coin@bsv.timer
    - enable: True

# This needs to be ran so we have data to work with as soon as possible.
# Sometimes bitcoinaverage's API can fail. We have some stub values, as of 2019-04-17
# that can be backups so we don't break an entire install.
hedron_fiat_per_coin_bch_prime:
  cmd.run:
    - name: systemctl start fiat_per_coin@bch || (echo 300 > /var/cache/fiat_per_coin/bch/even; echo 301 > /var/cache/fiat_per_coin/bch/odd)
    - creates:
      - /var/cache/fiat_per_coin/bch/even
      - /var/cache/fiat_per_coin/bch/odd

hedron_fiat_per_coin_btc_prime:
  cmd.run:
    - name: systemctl start fiat_per_coin@btc || (echo 5000 > /var/cache/fiat_per_coin/btc/even; echo 5001 > /var/cache/fiat_per_coin/btc/odd)
    - creates:
      - /var/cache/fiat_per_coin/btc/even
      - /var/cache/fiat_per_coin/btc/odd

hedron_fiat_per_coin_bsv_prime:
  cmd.run:
    - name: systemctl start fiat_per_coin@bsv || (echo 80 > /var/cache/fiat_per_coin/bsv/even; echo 81 > /var/cache/fiat_per_coin/btc/odd)
    - creates:
      - /var/cache/fiat_per_coin/bsv/even
      - /var/cache/fiat_per_coin/bsv/odd

# Verify things are working as they should be.
# Eventually, hopefully salt can actually test for creates arguments and except if they aren't made after the state is ran.
hedron_fiat_per_coin_btc_exists:
  file.exists:
    - name: /var/cache/fiat_per_coin/btc/even

hedron_fiat_per_coin_bch_exists:
  file.exists:
    - name: /var/cache/fiat_per_coin/bch/even

hedron_fiat_per_coin_bsv_exists:
  file.exists:
    - name: /var/cache/fiat_per_coin/bsv/even
