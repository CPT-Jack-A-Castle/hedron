{% if 'hedron.tor_persistent_keys' in pillar %}

{% for tor_private_key in pillar['hedron.tor_persistent_keys'] %}

# tor writes out the hostname for us.
hedron_tor_persistent_key_{{ tor_private_key }}:
  file.managed:
    - name: /etc/tor/{{ tor_private_key }}/private_key
    - contents_pillar: hedron.tor_persistent_keys:{{ tor_private_key }}
    - mode: 0600
    - user: debian-tor
    - makedirs: True

{% endfor %}

{% endif %}

{% if 'hedron.tor_persistent_keys_v3' in pillar %}

{% for tor_private_key_v3 in pillar['hedron.tor_persistent_keys_v3'] %}

# Make a stub file and directory if necessary
hedron_tor_persistent_key_{{ tor_private_key_v3 }}_stub:
  file.managed:
    - name: /etc/tor/{{ tor_private_key_v3 }}/hs_ed25519_secret_key
    - mode: 0600
    - user: debian-tor
    - makedirs: True

# tor writes out the hostname for us, even for V3 which has public key, private key, and hostname.
# FIXME: Does not support replacing keys that have already been added. Key file must be deleted or truncated/similar first.
# This does write the secret key plain text in some logs. This is worth investigating if it's a security risk or not, if any of those logs are world readable.
hedron_tor_persistent_key_{{ tor_private_key_v3 }}_write:
  cmd.run:
    - unless: grep secret /etc/tor/{{ tor_private_key_v3 }}/hs_ed25519_secret_key
    - name: echo {{ pillar["hedron.tor_persistent_keys_v3"][tor_private_key_v3] }} | base64 -d > /etc/tor/{{ tor_private_key_v3 }}/hs_ed25519_secret_key

{% endfor %}

{% endif %}
