# A wallet local to the system, handy for vmmanagement and such.

include:
  - hedron.file_helper

hedron_walkingliberty_local_wallet_directory:
  file.directory:
    - name: /etc/walkingliberty
    - mode: 0700

# pwgen is in hedron.base
# 41 bytes because of newline
hedron_walkingliberty_local_wallet_generation:
  cmd.run:
    - name: pwgen -s 40 1 | file_helper write_file_from_stdin --exactly_bytes 41 /etc/walkingliberty/private
    - umask: 0077
    - creates: /etc/walkingliberty/private

# Can consider opening up the permissions on these and the directory.
# 20 is a dumb value...
hedron_walkingliberty_local_wallet_btc:
  cmd.run:
    - name: walkingliberty --currency btc address $(cat /etc/walkingliberty/private) | file_helper write_file_from_stdin --atleast_bytes 20 /etc/walkingliberty/address_btc
    - umask: 0077
    - creates: /etc/walkingliberty/address_btc

hedron_walkingliberty_local_wallet_bch:
  cmd.run:
    - name: walkingliberty --currency bch address $(cat /etc/walkingliberty/private) | file_helper write_file_from_stdin --atleast_bytes 20 /etc/walkingliberty/address_bch
    - umask: 0077
    - creates: /etc/walkingliberty/address_bch

hedron_walkingliberty_local_wallet_bsv:
  cmd.run:
    - name: walkingliberty --currency bsv address $(cat /etc/walkingliberty/private) | file_helper write_file_from_stdin --atleast_bytes 20 /etc/walkingliberty/address_bsv
    - umask: 0077
    - creates: /etc/walkingliberty/address_bsv
