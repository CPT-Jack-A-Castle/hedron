include:
  - .dependencies

hedron_fiat_per_coin_library:
  file.managed:
    - name: /usr/local/lib/python3.5/dist-packages/fiat_per_coin.py
    - source: salt://hedron/fiat_per_coin/files/fiat_per_coin.py
    - mode: 0644

hedron_fiat_per_coin_executable:
  file.managed:
    - name: /usr/local/bin/fiat_per_coin
    - source: salt://hedron/fiat_per_coin/files/fiat_per_coin.py
    - mode: 0755
