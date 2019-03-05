hedron_ssh_ssh-keydgen_installed:
  file.managed:
    - name: /var/golang/bin/ssh-keydgen
    - source: https://github.com/cornfeedhobo/ssh-keydgen/releases/download/v0.3.0/ssh-keydgen_linux_amd64
    - source_hash: 86ab84a405f7057019721227e9506820f00093fa4968e739d685bd1994c0fda3
    - makedirs: True
    - mode: 0555
