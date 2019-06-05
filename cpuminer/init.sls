{% if 'hedron.cpuminer.enabled' in pillar %}
{% if pillar['hedron.cpuminer.enabled'] == False %}
{% set hedron_cpuminer_enabled = False %}
{% else %}
{% set hedron_cpuminer_enabled = True %}
{% endif %}
{% else %}
{% set hedron_cpuminer_enabled = True %}
{% endif %}

{% if hedron_cpuminer_enabled == False %}
hedron_cpuminer_service_dead:
  service.dead:
   - name: cpuminer
   - enable: False
{% else %}
include:
  - hedron.xmrig
  - .service
{% endif %}

