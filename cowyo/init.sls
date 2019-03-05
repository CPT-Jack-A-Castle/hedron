# cowyo is the server, cowyodel is the client.

include:
  - hedron.golang

hedron_cowyo_build:
  cmd.run:
    - name: go get -u github.com/schollz/cowyo
    - creates: /var/golang/bin/cowyo
    - env:
      - GOPATH: /var/golang
