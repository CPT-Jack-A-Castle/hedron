# Extension is Python 2 since this is Python 2. Also avoids flake8,
# which it fails badly. Should be cleaned up and ported eventually.

hedron_notbit_bitmessage_address_generator:
  file.managed:
    - name: /usr/local/bin/bitmessage_address_generator
    - mode: 0755
    - source: salt://hedron/notbit/files/bitmessage_address_generator.py2
