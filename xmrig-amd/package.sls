hedron_xmrig-amd_package_dependencies:
  pkg.installed:
    - pkgs:
      - build-essential
      - cmake
      - git
      - libuv1-dev
      - libmicrohttpd-dev
      - ocl-icd-opencl-dev

hedron_xmrig-amd_git_latest:
  git.latest:
    - name: https://github.com/xmrig/xmrig-amd.git
    - target: /usr/local/src/xmrig-amd
    - unless: test -d /usr/local/src/xmrig-amd

hedron_xmrig-amd_package_install:
  cmd.script:
    - name: salt://hedron/xmrig-amd/files/build.sh
    - cwd: /usr/local/src/xmrig-amd
    - creates: /usr/local/bin/xmrig-amd
