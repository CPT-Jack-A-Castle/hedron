# git is not technically a requirement, but go get github.com/.... is very common and we need it for that.
hedron_golang_dependencies:
  pkg.installed:
    - name: git

hedron_golang_archive:
  file.managed:
    - name: /srv/salt/dist/golang.tar.gz
    - source:
      - salt://dist/golang.tar.gz
      - https://dl.google.com/go/go1.12.1.linux-amd64.tar.gz
    - source_hash: 2a3fdabf665496a0db5f41ec6af7a9b15a49fbe71a85a50ca38b1f13a103aeec
    - makedirs: True

hedron_golang_directory:
  file.directory:
    - name: /usr/local/go
    - mode: 0755

# Archive is normally just "go/" but don't want to "trust" that, just in case.
hedron_golang_extracted:
  cmd.run:
    - name: tar --strip-components=1 --owner 0 --group 0 -xzf /srv/salt/dist/golang.tar.gz -C /usr/local/go
    - creates: /usr/local/go/bin/go

hedron_golang_symlink:
  file.symlink:
    - name: /usr/bin/go
    - target: /usr/local/go/bin/go
