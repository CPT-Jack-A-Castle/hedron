# Disables the node before expiry for graceful stopping.

# Sketchy about using a bin directory for this in case the administrator accidentally runs it since it's in PATH. Does have to be executable for systemd.

# Soft script most likely runs at a different time period than the hard script (maybe 25 hours out vs 1 hour out)

{% if 'hedron.sporestack' in pillar %}

{% for autodisable_type in ['soft', 'hard'] %}

{% if 'autodisable_' + autodisable_type + '_script' in pillar['hedron.sporestack'] %}

hedron_sporestack_autodisable_{{ autodisable_type }}_script:
  file.managed:
    - name: /var/tmp/autodisable-{{ autodisable_type }}
    - contents_pillar: hedron.sporestack:autodisable_{{ autodisable_type }}_script
    - mode: 0500

hedron_autodisable_autodisable_{{ autodisable_type }}_service:
  file.managed:
    - name: /etc/systemd/system/autodisable_{{ autodisable_type }}.service
    - replace: False
    - contents: |
        [Unit]
        Description=Autodisable {{ autodisable_type }} service
        [Service]
        Type=oneshot
        ExecStart=/var/tmp/autodisable-{{ autodisable_type }}
        [Install]
        WantedBy=multi-user.target

## Super hacky workaround for systemd bug + jinja2 limitations.

hedron_autodisable_{{ autodisable_type }}_date_formatter:
  cmd.run:
    - name: date -d @{{ pillar['hedron.sporestack'][ 'autodisable_' + autodisable_type + '_time'] }} '+%Y-%m-%d %H:%M:%S' > /var/tmp/autodisable_{{ autodisable_type }}_date
    - creates: /var/tmp/autodisable_{{ autodisable_type }}_date

# Unfortunately, systemd 232 does not support epochs in OnCalendar: https://github.com/systemd/systemd/pull/5947
# End of life time is slightly hacky, should be a grain ideally.
hedron_autodisable_{{ autodisable_type }}_timer:
  file.managed:
    - name: /etc/systemd/system/autodisable_{{ autodisable_type }}.timer
    - replace: False
    - contents: |
        [Unit]
        Description=Autodisable {{ autodisable_type }} timer
        [Timer]
        OnCalendar=REPLACEME
        [Install]
        WantedBy=multi-user.target

hedron_autodisable_{{ autodisable_type }}_timer_replace:
  cmd.run:
    - name: sed -i "s/REPLACEME/$(cat /var/tmp/autodisable_{{ autodisable_type }}_date)/" /etc/systemd/system/autodisable_{{ autodisable_type }}.timer
    - onlyif: grep REPLACEME /etc/systemd/system/autodisable_{{ autodisable_type }}.timer

##

hedron_autodisable_{{ autodisable_type }}_timer_running:
  service.running:
    - name: autodisable_{{ autodisable_type }}.timer
    - enable: True

{% endif %}

{% endfor %}

{% endif %}
