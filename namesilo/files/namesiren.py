#!/usr/bin/python3

"""
Namesilo...

So https://github.com/goranvrbaski/python-namesilo supports Python 3
but not registering nameservers. Looks like a better libary down the
road.

Manual Steps:

Register nameserver
"""

import logging

import namesilo
import aaargh

logging.basicConfig(level=logging.INFO)

cli = aaargh.App()


@cli.cmd
@cli.cmd_arg('apikey')
@cli.cmd_arg('domain')
@cli.cmd_arg('nameserver_index')
@cli.cmd_arg('ip4')
@cli.cmd_arg('ip6')
def set_ns_domain(apikey, domain, nameserver_index, ip4, ip6):
    """
    This is very ugly, hard to test, and extremely specific code.
    I'd like to make it less messy, but it'd be best to first start
    with the namesilo API itself.

    Anyway, this does very specific things. It sets a registered
    nameserver at NameSilo for a domain. Whether creating or
    updating, doesn't matter. Then if updates the nameservers on
    file if they need to be. So registering a nameserver (putting
    it on the TLD servers) does not automatically set the domain's
    nameservers.

    If it needs updating, we do that. Thus, servers can
    act indepedently as long as timing is off a little bit. Imagine
    there is some locking that could cause issues, so ideally do a
    random sleep and hope for the best.
    """
    NameSilo = namesilo.NameSilo(apikey, live=True)
    nameserver = 'ns' + nameserver_index
    # if it's here...
    nsoutput = NameSilo.list_registered_nameservers(domain=domain)
    existing_nameservers = []
    # if a domain has no nameservers, there's no hosts in the dict.
    # If it does and has one, hosts has a dict. If it has more than one,
    # hosts is a list of dicts.
    # Actually, if it has three, it's just super messed up.
    # Need to dict this library or fix it. Very bad.
    # It's like a list of lists, of dicts, then a dict in that first
    # list.
    if 'hosts' in nsoutput:
        if isinstance(nsoutput['hosts'], list):
            for host in nsoutput['hosts']:
                existing_nameservers.append(host['host'])
        else:
            existing_nameservers.append(nsoutput['hosts']['host'])
    if nameserver in existing_nameservers:
        all_nameservers = existing_nameservers
        NameSilo.update_registered_nameserver(domain=domain,
                                              current_host=nameserver,
                                              new_host=nameserver,
                                              ip1=ip4,
                                              ip2=ip6)
    else:
        all_nameservers = existing_nameservers + [nameserver]
        NameSilo.add_registered_nameserver(domain=domain,
                                           new_host=nameserver,
                                           ip1=ip4,
                                           ip2=ip6)
    # Now, check the nameservers set.
    all_nameservers_fqdn = []
    for nameserver in all_nameservers:
        all_nameservers_fqdn.append(nameserver + '.' + domain)
    needs_update = False
    nsoutput = NameSilo.get_domain_info(domain=domain)
    for nameserver in nsoutput['nameservers']['nameserver']:
        if nameserver.lower() not in all_nameservers_fqdn:
            needs_update = True
            break
    if len(nsoutput['nameservers']['nameserver']) != len(all_nameservers):
        needs_update = True
    if needs_update is True:
        # Only update if we have two nameservers or more.
        if len(all_nameservers) >= 2:
            # FIXME: Only supports two nameservers!
            # Not even sure how to do this properly.
            logging.info('Updating nameservers...')
            NameSilo.change_nameservers(domain=domain,
                                        ns1=all_nameservers_fqdn[0],
                                        ns2=all_nameservers_fqdn[1])
        else:
            logging.warning('Not enough nameservers to update.')
    return True


if __name__ == '__main__':
    output = cli.run()
    if output is True:
        exit(0)
    elif output is False:
        exit(1)
    else:
        print(output)
