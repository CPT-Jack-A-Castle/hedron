# Not having the en_US.utf8 locale can cause issues with some software like carml (Click on Python 3.5)
# https://click.palletsprojects.com/en/7.x/python3/

# We aren't attempting to fix the locale yet (local-gen en_US.UTF8 was generating a non-UTF-8 locale and not fixing anything for me), so just break if it's bad and we can improve this later.
# Better to catch errors here than later.

# One thing that definitely can fix it is dpkg-reconfigure locales

hedron_base_locale:
  cmd.run:
    - name: /bin/false
    - unless: 'locale -a | grep en_US.utf8'
