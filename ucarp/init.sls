hedron_ucarp_package:
  pkg.installed:
    - name: ucarp

# Eventually will need to be updated to support multiple ucarps.
{% if 'hedron.ucarp.srcip' in pillar %}
hedron_ucarp_service_file:
  file.managed:
    - name: /etc/systemd/system/ucarp.service
    - source: salt://hedron/ucarp/files/ucarp.service.jinja
    - template: jinja

hedron_ucarp_up_script:
  file.managed:
    - name: /etc/ucarp-up.sh
    - source: salt://hedron/ucarp/files/ucarp-up.sh
    - mode: 0555

hedron_ucarp_down_script:
  file.managed:
    - name: /etc/ucarp-down.sh
    - source: salt://hedron/ucarp/files/ucarp-down.sh
    - mode: 0555

hedron_ucarp_service_running:
  service.running:
    - name: ucarp
    - enable: True
    - watch:
      - file: /etc/systemd/system/ucarp.service
{% endif %}
