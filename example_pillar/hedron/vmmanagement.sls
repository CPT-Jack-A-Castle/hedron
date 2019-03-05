# Do not set to false! Unset key entirely!
# This has been removed, at least for now.
{% if grains['id'] == 'vmmanagement-super-special-host-1' %}
hedron_vmmanagement_custom_networking: True
{% endif %}
