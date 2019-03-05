# The client is cowyodel.

include:
  - hedron.golang

hedron_cowyo_client_build:
  cmd.run:
    - name: go get -u github.com/schollz/cowyodel
    - creates: /var/golang/bin/cowyodel
    - env:
      - GOPATH: /var/golang

# "installed", just a symlink into PATH
hedron_cowyo_client_installed:
  file.symlink:
    - name: /usr/local/bin/cowyodel
    - target: /var/golang/bin/cowyodel
