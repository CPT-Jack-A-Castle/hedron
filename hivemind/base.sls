# Hivemind

# Also requires hedron.tor.hiddensshd

include:
  - hedron.pip
  - hedron.notbit

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
