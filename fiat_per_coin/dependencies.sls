include:
  - hedron.pip.python3

hedron_fiat_per_coin_apt_dependencies:
  pkg.installed:
    - name: python3-dev

hedron_fiat_per_coin_dependencies:
  pip.installed:
    - pkgs:
      - aaargh
      - bitcoinacceptor>=0.3.2
    - bin_env: /usr/bin/pip3
