hedron_grafana_sample_ini:
  file.managed:
    - name: /etc/grafana/grafana.sample.ini
    - source: salt://hedron/grafana/files/grafana.ini
    - makedirs: True

# Copy this over if one isn't already there
hedron_grafana_ini_copy:
  file.copy:
    - name: /etc/grafana/grafana.ini
    - source: /etc/grafana/grafana.sample.ini
    - force: False
    - preserve: False

hedron_grafana_package_dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - python3-apt

hedron_grafana_package_repository:
  pkgrepo.managed:
    - name: deb https://packages.grafana.com/oss/deb stable main
    - key_url: salt://hedron/grafana/files/grafana.asc

hedron_grafana_package_installed:
  pkg.installed:
    - name: grafana
