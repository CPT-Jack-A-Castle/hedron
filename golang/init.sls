{% set version = '1.13.8' %}
{% set hash = '0567734d558aef19112f2b2873caa0c600f1b4a5827930eb5a7f35235219e9d8' %}

hedron_golang_archive:
  file.managed:
    - name: /srv/salt/dist/{{ hash }}-golang.tar.gz
    - source:
      - salt://dist/{{ hash }}-golang.tar.gz
      - https://dl.google.com/go/go{{ version }}.linux-amd64.tar.gz
    - source_hash: {{ hash }}
    - makedirs: True

hedron_golang_directory:
  file.directory:
    - name: /usr/local/go
    - mode: 0755

# Archive is normally just "go/" but don't want to "trust" that, just in case.
hedron_golang_extracted:
  cmd.run:
    - name: tar --strip-components=1 --owner 0 --group 0 -xzf /srv/salt/dist/{{ hash }}-golang.tar.gz -C /usr/local/go
    - creates: /usr/local/go/bin/go

hedron_golang_symlink:
  file.symlink:
    - name: /usr/bin/go
    - target: /usr/local/go/bin/go
