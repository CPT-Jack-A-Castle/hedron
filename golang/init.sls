{% set version = '1.13.4' %}
{% set hash = '692d17071736f74be04a72a06dab9cac1cd759377bd85316e52b2227604c004c' %}

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
