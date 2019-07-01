# Hivemind

# Also requires hedron.tor.hiddensshd to embed onion access into the messages.

include:
  - hedron.pip
  - hedron.notbit.package

# Need to include hedron.notbit before this state if you want to use Bitmessage.

hedron_hivemind_base_pip_dependencies:
  pip.installed:
    - pkgs:
      - aaargh
      - sh
    - bin_env: /usr/bin/pip3

hedron_hivemind_base_notbit_library:
  file.managed:
    - name: /usr/local/lib/python3.5/dist-packages/notbit.py
    - source: salt://hedron/hivemind/files/notbit.py
    - mode: 0644

hedron_hivemind_base_binary:
  file.managed:
    - name: /usr/local/bin/hivemind
    - source: salt://hedron/hivemind/files/hivemind.py
    - mode: 0755

hedron_hivemind_base_configuration:
  file.managed:
    - name: /etc/hivemind.json
    - source: salt://hedron/hivemind/files/hivemind.json.jinja
    - template: jinja
    - mode: 0400

# Hack to test configuration so we fail out if it's bad.
hedron_hivemind_valiadate_configuration:
  cmd.run:
    - name: hivemind get_config
    - unless: hivemind get_config
