"""

vmmanagement implementation for baremetal.

"""

import logging
import traceback

import hug
import statsd as libstatsd
from falcon import HTTP_400, HTTP_500
from sporestackv2 import validate

import vmmanagement_client_ssh as vmmanagement_client


logging.basicConfig(level=logging.INFO)

statsd = libstatsd.StatsClient('localhost', 8125)

LOCALHOST = '127.0.0.1'


@hug.get('/host_info', versions=2)
def host_info():
    """
    Info on the host
    """
    return vmmanagement_client.host_info(LOCALHOST)


@hug.post('/launch', versions=2)
def launch(machine_id,
           currency,
           cores,
           memory,
           disk,
           ipv4,
           ipv6,
           bandwidth,
           ipxescript,
           region=None,
           operating_system=None,
           ssh_key=None,
           want_topup=False,
           host=None,
           organization=None,
           days=0,
           settlement_token=None,
           override_code=None,
           hostaccess=False,
           refund_address=None,
           qemuopts=None,
           managed=False):
    """
    ssh_key and operating_system have no effect.
    """
    statsd.incr('vmmanagement_baremetal.launch')

    validate.ipv4(ipv4)
    validate.ipv6(ipv6)
    validate.bandwidth(bandwidth)
    validate.cores(cores)
    validate.disk(disk)
    validate.memory(memory)
    validate.organization(organization)
    validate.machine_id(machine_id)

    validate.ipxescript(ipxescript)
    validate.region(region)

    if region is not None:
        raise ValueError('Only None region supported for this host.')

    def create_vm():
        return vmmanagement_client.create(hostname=LOCALHOST,
                                          machine_id=machine_id,
                                          days=days,
                                          disk=disk,
                                          memory=memory,
                                          cores=cores,
                                          ipv4=ipv4,
                                          ipv6=ipv6,
                                          bandwidth=bandwidth,
                                          currency=currency,
                                          settlement_token=settlement_token,
                                          organization=organization,
                                          refund_address=refund_address,
                                          override_code=override_code,
                                          qemuopts=qemuopts,
                                          hostaccess=hostaccess,
                                          managed=managed)

    created_dict = create_vm()
    # paid and created should always be the same.
    if created_dict['paid'] is True:
        if vmmanagement_client.exists(LOCALHOST, machine_id) is not True:
            raise Exception('VM created but does not exist??')
        vmmanagement_client.ipxescript(LOCALHOST, machine_id, ipxescript)
        vmmanagement_client.start(LOCALHOST, machine_id)

    created_dict['host'] = host
    created_dict['machine_id'] = machine_id

    return created_dict


@hug.post('/topup', versions=2)
def topup(machine_id,
          days,
          currency,
          host=None,
          settlement_token=None):
    """
    tops up an existing vm.
    """
    validate.machine_id(machine_id)

    topup_dict = vmmanagement_client.topup(hostname=LOCALHOST,
                                           machine_id=machine_id,
                                           days=days,
                                           currency=currency,
                                           settlement_token=settlement_token)
    topup_dict['machine_id'] = machine_id
    return topup_dict


@hug.get('/info', versions=2)
def info(machine_id, host=None):
    """
    Info on the VM
    """
    validate.machine_id(machine_id)
    return vmmanagement_client.info(LOCALHOST, machine_id)


@hug.get('/status', versions=2)
def status(machine_id, host=None):
    """
    Checks if the VM is started or stopped.
    """
    output = {}
    validate.machine_id(machine_id)
    output['result'] = vmmanagement_client.status(LOCALHOST, machine_id)
    return output


@hug.get('/exists', versions=2)
def exists(machine_id, host=None):
    """
    Checks if the VM exists.
    """
    output = {}
    validate.machine_id(machine_id)
    output['result'] = vmmanagement_client.exists(LOCALHOST, machine_id)
    return output


@hug.post('/start', versions=2)
def start(machine_id, host=None):
    """
    Boots the VM.
    """
    validate.machine_id(machine_id)
    return vmmanagement_client.start(LOCALHOST, machine_id)


@hug.post('/stop', versions=2)
def stop(machine_id, host=None):
    """
    Immediately kills the VM.
    """
    validate.machine_id(machine_id)
    return vmmanagement_client.stop(LOCALHOST, machine_id)


@hug.post('/ipxescript', versions=2)
def ipxescript(machine_id, ipxescript, host=None):
    """
    Updates iPXE script for VM.
    """
    validate.machine_id(machine_id)
    return vmmanagement_client.ipxescript(LOCALHOST,
                                          machine_id,
                                          ipxescript=ipxescript)


@hug.post('/bootorder', versions=2)
def bootorder(machine_id, bootorder, host=None):
    validate.machine_id(machine_id)
    return vmmanagement_client.bootorder(hostname=LOCALHOST,
                                         machine_id=machine_id,
                                         bootorder=bootorder)


@hug.exception(ValueError)
@hug.exception(TypeError)
def hug_handle_exception(exception, response):
    response.status = HTTP_400
    logging.warning(exception)
    return str(exception)


@hug.exception(Exception)
def hug_handle_other_exceptions(exception, response):
    # 500s for these, since likely our failure and client should retry.
    response.status = HTTP_500
    logging.critical('Unhandled exception in vmmanagement_baremetal!')
    logging.warning(exception)
    traceback.print_exc()
    return "Something broke, please contact us."
