# Does not yet support Python 3.
# https://bitmessage_pybitmessage.org/wiki/Compiling_instructions
hedron_bitmessage_pybitmessage_dependencies:
  pkg.installed:
    - pkgs:
      - python
      - python-setuptools
      - libssl-dev
      - build-essential
      - python-msgpack
      - python-qt4

hedron_bitmessage_pybitmessage_source_archive:
  file.managed:
    - name: /srv/salt/dist/pybitmessage.tar.gz
    - source:
      - salt://dist/pybitmessage.tar.gz
      - https://github.com/Bitmessage/PyBitmessage/archive/ee7aa6c28de944fe6f5aff49c6b186449b75957a.tar.gz
    - source_hash: ebb3ca2eed0f40f4a2dcf6df3ff6a60504573abd37383309d62032c95706294e
    - makedirs: True
    - keep_source: False

hedron_bitmessage_pybitmessage_source_directory:
  file.directory:
    - name: /usr/local/src/pybitmessage

hedron_bitmessage_pybitmessage_source_extracted:
  cmd.run:
    - name: tar -xzf /srv/salt/dist/pybitmessage.tar.gz -C /usr/local/src/pybitmessage --strip-components=1
    - creates: /usr/local/src/pybitmessage/setup.py

# Ladies and gentlemen,
# I've written many hacks, many, many horrible hacks in this codebase.
# This one is particularly grave. I don't know if I should be more embarrased or more proud.
# Frankly, I feel a bit of both.
#
# The rationale:
# pybitmessage, launched via the sandbox, wants to change the permissions but cannot. If it could, we'd have problems as well.
# This is the easiest workaround that still lets us back things up with brainvault-persistence.
# I know a patch would have been more appropriate, but this works, possibly even more reliably than a patch on a changing codebase.
hedron_bitmessage_pybitmessage_installed:
  cmd.run:
    - name: "yes '\n' | python setup.py install; echo -e '\n\ndef fixSensitiveFilePermissions(filename, hasEnabledKeys):\n    return True' >> /usr/local/lib/python2.7/dist-packages/pybitmessage/shared.py"
    - cwd: /usr/local/src/pybitmessage
    - creates: /usr/local/bin/pybitmessage
