{% if grains['id'] == 'something-1' %}
hedron.ucarp.srcip: 192.168.32.1
{% elif grains['id'] == 'something-2' %}
hedron.ucarp.srcip: 192.168.32.2
{% endif %}
hedron.ucarp.addr: 192.168.32.32
hedron.ucarp.interface: mytincnetinterface
# Password has maximum length. Maybe 12?
hedron.ucarp.pass: opensesame
hedron.ucarp.vhid: 1
