{% set version = '1.13.5' %}
{% set hash = '512103d7ad296467814a6e3f635631bd35574cab3369a97a323c9a585ccaa569' %}

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
