#!/usr/bin/python3

import json

import vmmanagement_create


def host_info():
    """
    Returns a filtered set of data about the host.
    """
    config = vmmanagement_create.get_and_validate_config()
    available_resources = vmmanagement_create.get_available_resources()

    def _dict_to_list(dictionary):
        our_list = []
        for item in dictionary:
            our_list.append(item)
        return our_list

    currencies = _dict_to_list(config['currencies'])
    ipv4 = _dict_to_list(config['ipv4'])
    ipv6 = _dict_to_list(config['ipv6'])

    return_dict = {'cores': available_resources['cores'],
                   'memory': available_resources['memory'],
                   'disk': available_resources['disk'],
                   'ipv4_addresses': available_resources['ipv4_addresses'],
                   'currencies': currencies,
                   'ipv4': ipv4,
                   'ipv6': ipv6,
                   'draining': config['draining'],
                   'topup_enabled': config['topup_enabled'],
                   'max_cores_per_vm': config['max_cores_per_vm'],
                   'max_disk_per_vm': config['max_disk_per_vm'],
                   'max_memory_per_vm': config['max_memory_per_vm'],
                   'max_days': config['max_days'],
                   'features': ['ipxe']}

    return return_dict


if __name__ == '__main__':
    print(json.dumps(host_info()))
