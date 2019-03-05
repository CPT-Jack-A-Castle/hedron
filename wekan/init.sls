include:
  - hedron.docker
  - .hiddenservice

hedron_wekan_data_directory:
  file.directory:
    - name: /var/tmp/wekan/data
    - makedirs: True
    - mode: 700

# There is a theoretical race condition where Tor might not have generated the hidden service by the time we get here and try to insert it into ROOT_URL.
# Unfortunately, can't find a way to get rid of the ROOT_URL altogether. Not having it failed, using / fail, etc.
# FIXME: Not just theoretical but it has happened.
hedron_wekan_docker_compose_file:
  file.managed:
    - name: /var/tmp/wekan/docker-compose.yml
    - source: salt://hedron/wekan/files/docker-compose.yml.jinja
    - template: jinja

# docker-compose up is quite idempotent by itself, hence the weird hack.
hedron_wekan_docker_compose_running:
  cmd.run:
    - name: false
    - cwd: /var/tmp/wekan
    - unless: docker-compose up -d

# First account registered has admin. Any email works, no need for an invite code.

# JSON import is flakey between different versions, hence the old version pin.
# https://github.com/wekan/wekan/issues/1616
