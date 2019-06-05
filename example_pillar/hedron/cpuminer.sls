hedron.cpuminer:
  algorithm: cryptonight
  stratum: stratum+tcp://cryptonight.usa.nicehash.com:3355
  user: 1bitcoinaddress
  use_tor: True

{% if grains['id'].startswith('miner') %}
hedron.cpuminer.enabled: True
{% else %}
hedron.cpuminer.enabled: False
{% endif %}
