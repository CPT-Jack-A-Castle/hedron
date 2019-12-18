# Monitor prewarmed tornets. Failures should show up as systemd failed services.
# Severely idle Tor processes seem more likely to get in a useless, hung state.

{% if 'hedron_tor_slots' in grains %}
{% set tor_slots = grains['hedron_tor_slots'] %}
{% else %}
{% set tor_slots = 61 %}
{% endif %}
{% for slot in range(4000, 4000 + tor_slots) %}

# Appears we can also check for 8.8.8.8, which should return nothing, and
# DynamicUser=yes caues curl to error saying it's out of memory, at least on Debian 9.
# Same with User=nobody.
hedron_tornet_monitor_slot_{{ slot }}_service_file:
  file.managed:
    - name: /etc/systemd/system/tornet-monitor-slot{{ slot }}.service
    - contents: |
        [Unit]
        Description=Tornet alive checker for {{ slot }}
        [Service]
        ProtectSystem=yes
        Group=slot{{ slot }}
        Type=oneshot
        ExecStart=/usr/bin/curl -s --show-error --fail https://canhazip.com
        TimeoutSec=60
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_tornet_monitor_slot_{{ slot }}_service_timer_file:
  file.managed:
    - name: /etc/systemd/system/tornet-monitor-slot{{ slot }}.timer
    - contents: |
        [Unit]
        Description=Tornet alive checker timer for {{ slot }}
        [Timer]
        OnCalendar=hourly
        RandomizedDelaySec=3600
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .timer

hedron_tornet_monitor_slot_{{ slot }}_service_timer_running:
  service.running:
    - name: tornet-monitor-slot{{ slot }}.timer
    - enable: True
    - watch:
      - file: /etc/systemd/system/tornet-monitor-slot{{ slot }}.service
      - file: /etc/systemd/system/tornet-monitor-slot{{ slot }}.timer

{% endfor %}

# Helpful oneliner. Might want to verify there are no VMs on the given tornet before doing this.
#  for slot in $(systemctl list-units --state=failed | grep tornet-monitor | cut -d ' ' -f 2 | cut -d - -f 3 | cut -d . -f 1 | cut -d t -f 2); do systemctl restart tornet@1$slot; done; systemctl reset-failed
