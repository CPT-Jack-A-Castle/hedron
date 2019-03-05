hedron_cpuminer-multi_package_dependencies:
  pkg.installed:
    - pkgs:
      - build-essential
      - automake
      - pkg-config
      - git
      - libcurl4-openssl-dev
      - libjansson-dev
      - libssl-dev
      - libgmp-dev
      - zlib1g-dev

hedron_cpuminer-multi_package_install:
  cmd.script:
    - name: salt://hedron/cpuminer-multi/files/build.sh
    - creates: /usr/local/bin/cpuminer
