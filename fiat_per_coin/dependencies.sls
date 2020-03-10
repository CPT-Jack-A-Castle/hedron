include:
  - hedron.pip.python3

# Something under bitcoinacceptor needs to compile, meh.
hedron_fiat_per_coin_apt_dependencies:
  pkg.installed:
    - pkgs:
      - python3-dev
      - build-essential

hedron_fiat_per_coin_dependencies:
  pip.installed:
    - pkgs:
      - aaargh
      - bitcoinacceptor>=0.5.0
    - bin_env: /usr/bin/pip3
