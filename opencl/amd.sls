include:
  - .base

# firmware-linux pulls in some amd gpu firmware.
hedron_opencl_amd_dependenices:
  pkg.installed:
    - pkgs:
      - dkms
      - firmware-linux

# This step seems to fail with curl.
# May have to do it manually with a browser and then move it there.
# Also, archive is massive -- 300MiB +

# FIXME: curl --referer "https://support.amd.com" works with this. No need for -L, even.
hedron_opencl_amd_download:
  file.managed:
    - name: /var/tmp/amdgpu.tar.xz
    - source: https://www2.ati.com/drivers/linux/ubuntu/amdgpu-pro-17.40-492261.tar.xz
    - source_hash: b0645157577c9ff175dc02487c4c682ded2624c8c2cfd6aa603960962e1d07b0
    - replace: False
    - keep_source: False

hedron_opencl_amd_directory:
  file.directory:
    - name: /var/tmp/amdgpu

hedron_opencl_amd_extract:
  cmd.run:
    - name: tar -xf /var/tmp/amdgpu.tar.xz --strip-components=1
    - cwd: /var/tmp/amdgpu
    - creates: /var/tmp/amdgpu/Release

hedron_opencl_amd_install:
  cmd.script:
    - source: salt://hedron/opencl/files/amd.sh
    - creates: /opt/amdgpu-pro/bin/clinfo
    - cwd: /var/tmp/amdgpu

# Most likely have to reboot after this. Check if it worked with 'clinfo'
