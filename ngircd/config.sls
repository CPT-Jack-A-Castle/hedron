# If you provide ngircd/files/ngircd.conf.jinja, it'll be loaded by default.
hedron_ngircd_config:
  file.managed:
    - name: /etc/ngircd/ngircd.conf
    - template: jinja
    - source:
        - salt://ngircd/files/ngircd.conf.jinja
        - salt://hedron/ngircd/files/ngircd.conf.jinja
