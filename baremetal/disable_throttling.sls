# Throttling is the difference between 50 hashes per second and 85 hashes per second with Monero mining.
# Default governor seems to keep "turbo" from being turned on and going up to 3.4GHz.

# FIXME: This should be configurable in Pillar.

hedron_baremetal_disable_throttling_packages:
  pkg.installed:
    - pkgs:
      - i7z
      - cpufrequtils

hedron_baremetal_disable_throttling_cpufreq_governor_setting:
  file.managed:
    - name: /etc/default/cpufrequtils
    - contents: GOVERNOR="performance"

hedron_baremetal_disable_throttling_cpufreq_restart:
  service.running:
    - name: cpufrequtils
    - enable: True
    - watch:
      - file: /etc/default/cpufrequtils
