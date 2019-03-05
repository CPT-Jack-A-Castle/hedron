#!/usr/bin/python3

import sys

import aaargh

cli = aaargh.App()


def validate_input(input,
                   atleast_bytes=False,
                   atmost_bytes=False,
                   exactly_bytes=False):

    input_length = len(input)

    if atmost_bytes is not False:
        if input_length > atmost_bytes:
            msg = '{} input bytes exceeds atmost_bytes'.format(input_length)
            raise ValueError(msg)

    if atleast_bytes is not False:
        if input_length < atleast_bytes:
            msg = '{} input bytes less than atleast_bytes'.format(input_length)
            raise ValueError(msg)

    if exactly_bytes is not False:
        if input_length != exactly_bytes:
            msg = '{} input bytes is not exactly_bytes'.format(input_length)
            raise ValueError(msg)

    return True


def write_file(input,
               filename,
               atleast_bytes=False,
               atmost_bytes=False,
               exactly_bytes=False,
               exclusive=False):
    validate_input(input=input,
                   atleast_bytes=atleast_bytes,
                   atmost_bytes=atmost_bytes,
                   exactly_bytes=exactly_bytes)

    if exclusive is True:
        file_mode = 'xb'
    else:
        file_mode = 'wb'

    with open(filename, file_mode) as fp:
        fp.write(input)


@cli.cmd
@cli.cmd_arg('filename')
@cli.cmd_arg('--atleast_bytes', type=int, default=False)
@cli.cmd_arg('--atmost_bytes', type=int, default=False)
@cli.cmd_arg('--exactly_bytes', type=int, default=False)
@cli.cmd_arg('--exclusive', type=bool, default=False)
def write_file_from_stdin(filename,
                          atleast_bytes=False,
                          atmost_bytes=False,
                          exactly_bytes=False,
                          exclusive=False):
    input = sys.stdin.buffer.read()
    write_file(input=input,
               filename=filename,
               atleast_bytes=atleast_bytes,
               atmost_bytes=atmost_bytes,
               exactly_bytes=exactly_bytes,
               exclusive=exclusive)


if __name__ == '__main__':
    output = cli.run()
    if output is True:
        sys.exit(0)
    elif output is False:
        sys.exit(1)
    elif output is None:
        sys.exit(0)
    else:
        if isinstance(output, bytes):
            sys.stdout.buffer.write(output)
        else:
            sys.stdout.write(output)
