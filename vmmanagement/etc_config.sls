# Helpers for the rest of vmmanagement stuff, like ipv6 prefix and others

# These are intended to be accurate, but not foolproof. So review config before using.

hedron_vmmanagement_etc_config_directory:
  file.directory:
    - name: /etc/vmmanagement
    - mode: 0700

hedron_vmmanagement_etc_config_ipv6:
  cmd.run:
    - creates: /etc/vmmanagement/ipv6_prefix
    - name: "ip -6 a | grep inet6 | grep -e mngtmpaddr -e global | head -n 1 | awk '{print $2'} | cut -d : -f -4 > /etc/vmmanagement/ipv6_prefix"

# These are all very hacky... should probably just be Pillar.
hedron_vmmanagement_etc_config_organizations:
  file.managed:
    - name: /etc/vmmanagement/organizations
    - contents: '[]'
    - replace: False

hedron_vmmanagement_etc_config_settlemers_endpoint:
  file.managed:
    - name: /etc/vmmanagement/settlers_endpoint
    - contents: 'null'
    - replace: False
