{% if 'hedron.sporestack.hosted' in grains %}
hedron.sporestack:
  autodisable_soft_script: |
    #!/bin/sh
    echo soft disable

  autodisable_hard_script: |
    #!/bin/sh
    echo hard disable

{% if grains['hedron.sporestack.hosted'] == True %}
  autodisable_soft_time: {{ grains['hedron.sporestack.end_of_life'][0]|int - 91000 }}
  autodisable_hard_time: {{ grains['hedron.sporestack.end_of_life'][0]|int - 4100 }}
{% else %}
  autodisable_soft_time: 0
  autodisable_hard_time: 0
{% endif %}
{% endif %}

