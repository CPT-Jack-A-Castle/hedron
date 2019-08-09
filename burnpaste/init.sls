# Built from: https://github.com/teran-mckinney/burnpaste

{% set hash = 'df79b50351a5da66fe0718fe92c3847eb42544924f4d2cf455137bf4bbf107f3' %}

hedron_burnpaste_installed:
  file.managed:
    - name: /usr/local/bin/burnpaste
    - source:
      - /srv/files/decensor/assets/{{ hash }}
      - https://go-beyond.org/decensor/asset/{{ hash }}
    - source_hash: {{ hash }}
    - mode: 0755

# burnpaste listens on :2323
hedron_burnpaste_service_file:
  file.managed:
    - name: /etc/systemd/system/burnpaste.service
    - contents: |
        [Unit]
        Description=burnpaste burn-on-reading pastebin
        [Service]
        DynamicUser=yes
        ExecStart=/usr/local/bin/burnpaste
        RuntimeDirectory=burnpaste
        WorkingDirectory=/run/burnpaste
        ProtectSystem=strict
        NoNewPrivileges=yes
        UMask=0077
        Restart=on-failure
        [Install]
        WantedBy=multi-user.target
    - check_cmd: systemd-analyze verify
    - tmp_ext: .service

hedron_burnpaste_service_running:
  service.running:
    - name: burnpaste
    - enable: True
    - watch:
      - file: /etc/systemd/system/burnpaste.service
      - file: /usr/local/bin/burnpaste
