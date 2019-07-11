import sh


def _sendmail_format(from_address, to_address, message, subject=None):
    """
    Returns message in a sendmail compatible format.
    ...from is a reserved keyword in python
    """
    formatted_message = "From: {}@bitmessage\n".format(from_address)
    formatted_message += "To: {}@bitmessage\n".format(to_address)
    if subject is not None:
        formatted_message += "Subject: {}\n".format(subject)
    formatted_message += "\n"
    formatted_message += message
    return formatted_message


def _read_keys_dot_dat():
    with open('/var/lib/notbit/keys.dat') as keys_dot_dat:
        return keys_dot_dat.read()


def _get_all_from_addresses():
    keys_dot_dat = _read_keys_dot_dat()
    addresses = []
    for line in keys_dot_dat.splitlines():
        if '[' in line and ']' in line:
            addresses.append(line.strip('[]'))
    if addresses == []:
        raise ValueError('No addresses in keys.dat')
    return addresses


def _get_from_address():
    return _get_all_from_addresses()[0]


def send_message(address, message, subject=None):
    """
    Sends a message to address over the Bitmessage network.
    Note that this is asyncronous.
    """
    from_address = _get_from_address()
    formatted_message = _sendmail_format(from_address,
                                         address,
                                         message,
                                         subject)
    sh.notbit_sendmail_system(_in=formatted_message)
    return True
