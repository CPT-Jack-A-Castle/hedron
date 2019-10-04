# bob's password is iambob
# alice's password is iamalice
# Generate passwords with: openssl passwd -1
hedron.users:
  bob:
    uid: 2000
    gid: hedron
    groups:
      - hedron-admins
    password: $1$1UrREK6t$.H.4bWnTyc3FU/Jpg32D9.
    ssh_public: ssh-rsa wowkey
    ssh_private: |
      -----BEGIN RSA PRIVATE KEY-----
      -----END RSA PRIVATE KEY-----
  alice:
    uid: 2001
    gid: hedron
    groups:
      - hedron-admins
    password: $1$LjsdLmF4$/FRS2ENiEDolS.GoAbmNK.
    ssh_public: ssh-rsa wowkey
    ssh_private: |
      -----BEGIN RSA PRIVATE KEY-----
      -----END RSA PRIVATE KEY-----

# Lock out root account from local login.
hedron.users.root_password: '!'
