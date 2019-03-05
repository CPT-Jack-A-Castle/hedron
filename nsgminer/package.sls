hedron_cpuminer_package_dependencies:
  pkg.installed:
    - pkgs:
      - build-essential
      - automake
      - pkg-config
      - git
      - libcurl4-openssl-dev
      - ocl-icd-opencl-dev
      - libssl-dev


hedron_nsgminer_git_latest:
  git.latest:
    - name: https://github.com/ghostlander/nsgminer.git
    - target: /usr/local/src/nsgminer
    - unless: test -d /usr/local/src/nsgminer

hedron_nsgminer_package_install:
  cmd.script:
    - name: salt://hedron/nsgminer/files/build.sh
    - cwd: /usr/local/src/nsgminer
    - creates: /usr/local/bin/nsgminer
