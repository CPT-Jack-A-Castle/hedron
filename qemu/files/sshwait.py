#!/usr/bin/python3

from sys import stderr, argv
from time import sleep

from paramiko import SSHClient, AuthenticationException, AutoAddPolicy


def main():
    hostname = argv[1]
    sshwait(hostname)


def sshwait(hostname):
    ssh_client = SSHClient()
    ssh_client.set_missing_host_key_policy(AutoAddPolicy())
    while True:
        try:
            ssh_client.connect(hostname=hostname,
                               username='dontletmein',
                               password='dontletmein',
                               allow_agent=False,
                               look_for_keys=False)
        except AuthenticationException:
            break
        except Exception:
            pass

        stderr.write('Waiting for server to come online.\n')
        sleep(15)
    ssh_client.close()
    return True


if __name__ == '__main__':
    main()
