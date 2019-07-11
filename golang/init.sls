# git is not technically a requirement, but go get github.com/.... is very common and we need it for that.
hedron_golang_dependencies:
  pkg.installed:
    - name: git

hedron_golang_archive:
  file.managed:
    - name: /srv/salt/dist/golang.tar.gz
    - source:
      - salt://dist/golang.tar.gz
      - https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz
    - source_hash: 66d83bfb5a9ede000e33c6579a91a29e6b101829ad41fffb5c5bb6c900e109d9
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
