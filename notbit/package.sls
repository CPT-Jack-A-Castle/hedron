# notbit is a Bitmessage client written in C.

hedron_notbit_package_dependencies:
  pkg.installed:
    - pkgs:
      - build-essential
      - autoconf
      - automake

# libssl1.0-dev causes a flip-flop with packages requiring libssl-dev (1.1)
# pkgconf also does this with pkg-config.
# Only install it if /usr/local/bin/notbit does not exist.
# Doing test -f instead of creates because creates might one day test if
# the thing was created after the cmd.run and error if not. Which, this
# command alone would not create that file.
hedron_notbit_package_libssl:
  cmd.run:
    - name: apt-get install -y libssl1.0-dev pkgconf
    - unless: test -f /usr/local/bin/notbit

hedron_notbit_package_source_archive:
  file.managed:
    - name: /srv/salt/dist/notbit.tar.gz
    - source:
      - salt://dist/notbit.tar.gz
      - https://github.com/bpeel/notbit/archive/5cdb2396860c6815545d057c85dc638e8e13da18.tar.gz
    - source_hash: 0398533bd7902b8daf4fdfa517e38e6ddbfded8dac85f170b07cbe29f0b25ccd
    - makedirs: True

hedron_notbit_package_source_directory:
  file.directory:
    - name: /usr/local/src/notbit

hedron_notbit_package_source_extracted:
  cmd.run:
    - name: tar -xzf /srv/salt/dist/notbit.tar.gz -C /usr/local/src/notbit --strip-components=1
    - creates: /usr/local/src/notbit/autogen.sh

hedron_notbit_package_installed:
  cmd.script:
    - source: salt://hedron/notbit/files/notbit_install.sh
    - creates: /usr/local/bin/notbit
    - cwd: /usr/local/src/notbit

# These are for use with the service, but they are in package
# so we can still do nosetests on hivemind by only installing
# hedron.notbit.package in develop_this

hedron_notbit_package_keygen_system:
  file.managed:
    - name: /usr/local/bin/notbit-keygen-system
    - mode: 0755
    - contents: |
        #!/bin/sh
        XDG_RUNTIME_DIR=/run/notbit /usr/local/bin/notbit-keygen $*

# No $* on this, maybe because of a slight bug and not really needed.
# Should be looked into again. Would say the address was bad sometimes?
# Gets the addresses from the to/from in the body, anyway.
# Or maybe... likely, this has zero effect.
hedron_notbit_package_sendmail_system:
  file.managed:
    - name: /usr/local/bin/notbit-sendmail-system
    - mode: 0755
    - contents: |
        #!/bin/sh
        XDG_RUNTIME_DIR=/run/notbit /usr/local/bin/notbit-sendmail
