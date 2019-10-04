# Hivemind

# Also requires hedron.tor.hiddensshd to embed onion access into the messages.

include:
  - hedron.pip

# Need to include hedron.notbit before this state if you want to use Bitmessage.

hedron_hivemind_base_pip_dependencies:
  pip.installed:
    - pkgs:
      - aaargh
      - sh
    - bin_env: /usr/bin/pip3

hedron_hivemind_base_notbit_library:
  file.managed:
    - name: {{ grains['hedron.python.dist.path'] }}/notbit.py
    - source: salt://hedron/hivemind/files/notbit.py
    - mode: 0644

hedron_hivemind_base_binary:
  file.managed:
    - name: /usr/local/bin/hivemind
    - source: salt://hedron/hivemind/files/hivemind.py
    - mode: 0755

hedron_hivemind_base_configuration:
  file.serialize:
    - name: /etc/hivemind.json
    - dataset_pillar: hedron.hivemind
    - mode: 0400
    - formatter: json
# https://github.com/saltstack/salt/issues/53982
#    - check_cmd: hivemind get_config --config_file
# Hack for now:
hedron_hivemind_base_configuration_verify:
  cmd.run:
    - name: hivemind get_config --config_file /etc/hivemind.json
    - unless: hivemind get_config --config_file /etc/hivemind.json
