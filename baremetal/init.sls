{% if grains['virtual'] == 'physical' %}

include:
  - .laptop
  - .disable_throttling
  - .extras

{% endif %}
