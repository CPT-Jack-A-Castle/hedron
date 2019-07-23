hedron_grafana_package_dependencies:
  pkg.installed:
    - name: apt-transport-https

hedron_grafana_package_repository:
  pkgrepo.managed:
    - name: deb https://packages.grafana.com/oss/deb stable main
    - key_url: salt://hedron/grafana/files/grafana.asc

hedron_grafana_package_installed:
  pkg.installed:
    - name: grafana
