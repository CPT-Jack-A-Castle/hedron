# Only run this once per the system being alive

hedron_hivemind_hello_world:
  cmd.run:
      - name: /usr/local/bin/hivemind hello_world && touch /var/tmp/hello_worlded
      - creates: /var/tmp/hello_worlded
