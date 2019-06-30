# A wallet local to the system, handy for vmmanagement and such.

include:
  - hedron.file_helper

hedron_walkingliberty_local_wallet_directory:
  file.directory:
    - name: /etc/walkingliberty
    - mode: 0700

{% for currency in ['btc', 'bch', 'bsv'] %}

# pwgen is in hedron.base
# 41 bytes because of newline
hedron_walkingliberty_local_wallet_private_{{ currency }}:
  cmd.run:
    - name: pwgen -s 40 1 | file_helper write_file_from_stdin --exactly_bytes 41 /etc/walkingliberty/private_{{ currency }}
    - umask: 0077
    - creates: /etc/walkingliberty/private_{{ currency }}

# 20 is a dumb value, but works.
hedron_walkingliberty_local_wallet_address_{{ currency }}:
  cmd.run:
    - name: walkingliberty --currency {{ currency }} address $(cat /etc/walkingliberty/private_{{ currency }}) | file_helper write_file_from_stdin --atleast_bytes 20 /etc/walkingliberty/address_{{ currency }}
    - umask: 0077
    - creates: /etc/walkingliberty/address_{{ currency }}

{% endfor %}
