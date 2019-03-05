include:
  - hedron.tor
  - hedron.golang

hedron_obfs4_packages_go_get:
  cmd.run:
    - name: go get git.torproject.org/pluggable-transports/obfs4.git/obfs4proxy
    - creates: /var/golang/bin/obfs4proxy
    - env:
      - GOPATH: /var/golang
