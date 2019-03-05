import pytest
from mock import patch

from vmmanagement_interface import (ebtables_arguments,
                                    slot_to_vm,
                                    route,
                                    _route_command,
                                    _default_route_parse)


mac = '52:54:00:12:34:56'
ip6 = '2001:db8::5054:00ff:fe12:3456'

vm_info = {"slot": 4003,
           "ipv4": "/32",
           "expiration": 0,
           "machine_id": "justamachine",
           "cores": 2,
           "bandwidth": -1,
           "txid": None,
           "hostaccess": False,
           "currency": None,
           "disk": 20,
           "qemuopts": "-display sdl -vga virtio -usb -soundhw hda -no-quit",
           "managed": True,
           "ipv6": "/128",
           "network_interfaces": [{"mac": mac,
                                   "ipv6": ip6}],
           "memory": 2,
           "bootorder": "cn"}

expected_up = (('-A', 'FORWARD', '-i', 'slot4003', '-s', mac, '-p', 'IPv4',
                '-j', 'ACCEPT', '--concurrent'),
               ('-A', 'FORWARD', '-i', 'slot4003', '-s', mac, '-p', 'IPv6',
                '-j', 'ACCEPT', '--concurrent'),
               ('-A', 'FORWARD', '-i', 'slot4003', '-s', mac, '-p', 'ARP',
                '-j', 'ACCEPT', '--concurrent'),
               ('-A', 'FORWARD', '-i', 'slot4003', '-j', 'DROP',
                '--concurrent'),
               ('-A', 'OUTPUT', '-o', 'slot4003', '-p', 'IPv4',  '-j',
                'ACCEPT', '--concurrent'),
               ('-A', 'OUTPUT', '-o', 'slot4003', '-p', 'IPv6',  '-j',
                'ACCEPT', '--concurrent'),
               ('-A', 'OUTPUT', '-o', 'slot4003', '-p', 'ARP',  '-j',
                'ACCEPT', '--concurrent'),
               ('-A', 'OUTPUT', '-o', 'slot4003', '-j', 'DROP',
                '--concurrent'))

v6_only_up = (('-A', 'FORWARD', '-i', 'slot4003', '-s', mac, '-p', 'IPv6',
               '-j', 'ACCEPT', '--concurrent'),
              ('-A', 'FORWARD', '-i', 'slot4003', '-j', 'DROP',
               '--concurrent'),
              ('-A', 'OUTPUT', '-o', 'slot4003', '-p', 'IPv6',  '-j',
               'ACCEPT', '--concurrent'),
              ('-A', 'OUTPUT', '-o', 'slot4003', '-j', 'DROP',
               '--concurrent'))


@patch('hedron.virtual_machine_info')
def test_ebtables_arguments(mock_virtual_machine_info):
    mock_virtual_machine_info.return_value = vm_info
    assert ebtables_arguments(vm='justamachine', up=True) == expected_up
    vm_info['ipv4'] = None
    assert ebtables_arguments(vm='justamachine', up=True) == v6_only_up


@patch('hedron.list_virtual_machines')
@patch('hedron.virtual_machine_info')
def test_slot_to_vm(mock_virtual_machine_info,
                    mock_list_virtual_machines):
    mock_virtual_machine_info.return_value = vm_info
    mock_list_virtual_machines.return_value = ['justamachine']
    assert slot_to_vm('slot4003') == 'justamachine'
    with pytest.raises(ValueError):
        slot_to_vm('slot4055')


def test_route_command():
    ip6_with_cidr = ip6 + '/128'
    expected = ('ro', 'add', ip6_with_cidr, 'dev', 'primary')
    assert _route_command('add', ip6) == expected


def test_route():
    with pytest.raises(ValueError):
        route('invalid_method', ip6)


ip_ro_output = """
fe80::/64 dev eth0 proto kernel metric 256  pref medium
fec0::/64 dev eth0 proto kernel metric 256  expires 86046sec pref medium
default via fe80::2 dev eth0 proto ra metric 1024  expires 1446sec
"""


def test_default_route_parse():
    assert _default_route_parse(ip_ro_output) == 'eth0'
