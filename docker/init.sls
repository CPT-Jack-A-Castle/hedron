# Installs docker and docker compose.

# https://docs.docker.com/engine/installation/linux/docker-ce/debian/

# There is a docker service that is enabled by default. Not sure if it will start the containers or not for us. Will find out.

hedron_docker_apt_deps:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - python-apt
      - ca-certificates
      - curl
      - gnupg2
      - software-properties-common

hedron_docker_repository:
  pkgrepo.managed:
    - name: deb [arch=amd64] https://download.docker.com/linux/debian stretch stable
    - key_url: salt://hedron/docker/files/docker.asc

hedron_docker_install:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-compose
