# A lot of packages install cron services that can do unexpected things. One of these is automatic updates. Particularly dangerous when we are rewriting service files with Salt and they install the old service file, then try to restart the service. We need to handle automatic updates in some fashion, but not yet.

hedron_base_disable_cron:
  service.dead:
    - name: cron
    - enable: False

hedron_base_disable_cron_timer:
  service.dead:
    - name: anacron.timer
    - enable: False

hedron_base_disable_apt_daily_timer:
  service.dead:
    - name: apt-daily.timer
    - enable: False

hedron_base_disable_apt_daily_upgrade_timer:
  service.dead:
    - name: apt-daily-upgrade.timer
    - enable: False
