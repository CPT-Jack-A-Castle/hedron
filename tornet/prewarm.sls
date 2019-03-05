{% if 'hedron_tor_slots' in grains %}
{% set tor_slots = grains['hedron_tor_slots'] %}
{% else %}
{% set tor_slots = 61 %}
{% endif %}
{% for slot in range(4000, 4000 + tor_slots) %}
hedron_tornet_prewarm_slot_{{ slot }}:
  service.running:
    - name: tornet@1{{ slot }}
    - enable: True
{% endfor %}
