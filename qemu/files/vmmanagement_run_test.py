from mock import patch

import vmmanagement_run


def test_ipxe_iso_argument():
    expected = ['-cdrom', '/home/vmmanagement/justavm/ipxe.iso']
    assert vmmanagement_run.ipxe_iso_argument('justavm') == expected


@patch('hedron.virtual_machine_info')
def test_get_gid(mock_virtual_machine_info):
    mock_virtual_machine_info.return_value = {'slot': 4000,
                                              'ipv4': 'tor',
                                              'ipv6': 'tor'}
    assert vmmanagement_run.get_gid('vm') == 4000
    mock_virtual_machine_info.return_value = {'slot': 4001,
                                              'ipv4': 'tor',
                                              'ipv6': False}
    assert vmmanagement_run.get_gid('vm') == 4001
    mock_virtual_machine_info.return_value = {'slot': 4002,
                                              'ipv4': False,
                                              'ipv6': 'tor'}
    assert vmmanagement_run.get_gid('vm') == 4002
    mock_virtual_machine_info.return_value = {'slot': 4000,
                                              'ipv4': 'nat',
                                              'ipv6': 'nat'}
    assert vmmanagement_run.get_gid('vm') == 1194
    mock_virtual_machine_info.return_value = {'slot': 4000,
                                              'ipv4': '/32',
                                              'ipv6': '/128'}
    assert vmmanagement_run.get_gid('vm') == 1194


vm_info = {"slot": 4003,
           "ipv4": "tor",
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
           "ipv6": "tor",
           "memory": 2,
           "network_interfaces": [{}],
           "bootorder": "cn"}


@patch('hedron.virtual_machine_info')
def test_boot_order_argument(mock_virtual_machine_info):
    our_vm_info = vm_info.copy()
    mock_virtual_machine_info.return_value = our_vm_info
    expected = ['-boot', 'order=cd']
    assert vmmanagement_run.boot_order_argument('justamachine') == expected
    our_vm_info['bootorder'] = 'c'
    expected = ['-boot', 'order=c']
    assert vmmanagement_run.boot_order_argument('justamachine') == expected
    our_vm_info['bootorder'] = 'n'
    expected = ['-boot', 'order=d']
    assert vmmanagement_run.boot_order_argument('justamachine') == expected


@patch('hedron.virtual_machine_info')
def test_drive_argument(mock_virtual_machine_info):
    our_vm_info = vm_info.copy()
    mock_virtual_machine_info.return_value = our_vm_info
    output = vmmanagement_run.drive_argument('justamachine')
    assert 'qcow2' in output
    our_vm_info['disk'] = 0
    mock_virtual_machine_info.return_value = our_vm_info
    output = vmmanagement_run.drive_argument('justamachine')
    assert output is None


expected_usermode = ['-net', 'nic,model=virtio', '-net',
                     'user,hostfwd=tcp:127.0.0.1:4003-:22']
expected_hostaccess = ['-net', 'nic,model=virtio', '-net', 'user,hostfwd=tcp:'
                       '127.0.0.1:4003-:22,guestfwd=tcp:10.0.2.1:1-tcp:'
                       '127.0.0.1:22']
expected_native = ['-device', 'virtio-net-pci,netdev=primary,mac='
                   '52:54:00:12:34:56', '-netdev',
                   'tap,id=primary,br=primary,ifname=slot4003']


@patch('hedron.virtual_machine_info')
def test_network_argument(mock_virtual_machine_info):
    our_vm_info = vm_info.copy()
    mock_virtual_machine_info.return_value = our_vm_info
    output = vmmanagement_run.network_argument('justamachine')
    assert output == expected_usermode

    our_vm_info['hostaccess'] = True
    output = vmmanagement_run.network_argument('justamachine')
    assert output == expected_hostaccess

    our_vm_info['ipv4'] = '/32'
    our_vm_info['ipv6'] = '/128'
    our_vm_info['hostaccess'] = False
    our_vm_info['network_interfaces'][0]['mac'] = '52:54:00:12:34:56'
    output = vmmanagement_run.network_argument('justamachine')
    assert output == expected_native
    our_vm_info['ipv4'] = None
    output = vmmanagement_run.network_argument('justamachine')
    assert output == expected_native


expected = ['-name', 'justamachine', '-smp', 2, '-m', '2G', '-cpu', 'kvm64',
            '-enable-kvm', '-nodefaults', '-monitor', 'none', '-qmp',
            'unix:/run/runqemu@justamachine/qmp,server,nowait', '-display',
            'sdl', '-vga', 'virtio',
            '-usb', '-soundhw', 'hda', '-no-quit', '-drive',
            'file=/var/tmp/runqemu/justamachine/disk.qcow2,format=qcow2,'
            'cache=writeback,discard=unmap,detect-zeroes=unmap,if=virtio',
            '-serial',
            'unix:/home/vmmanagement/justamachine/serial,server,nowait',
            '-net', 'nic,model=virtio', '-net',
            'user,hostfwd=tcp:127.0.0.1:4003-:22', '-cdrom',
            '/home/vmmanagement/justamachine/ipxe.iso', '-boot', 'order=cd']


@patch('hedron.virtual_machine_info')
def test_qemu_arguments(mock_virtual_machine_info):
    mock_virtual_machine_info.return_value = vm_info
    assert vmmanagement_run.qemu_arguments('justamachine') == expected
