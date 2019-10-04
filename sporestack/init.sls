include:
  - hedron.pip.python3

{% set version = '1.1.1' %}

hedron_sporestack_pip_installed:
  pip.installed:
    - name: sporestack=={{ version }}
    - bin_env: /usr/bin/pip3

# Sometimes, even though sporestack depends on requets[socks]>=2.22.0, the dependency doesn't get pulled in.
# pip bug? Dunno.
# This is a hack to hopefully make that happen.
hedron_sporetack_pip_installed_hack:
  cmd.run:
    - name: pip3 install sporestack=={{ version }}
    - unless: pip3 install sporestack=={{ version }}
