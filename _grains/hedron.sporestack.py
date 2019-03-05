#!/usr/bin/env python

# Can't find a way to do top file matches to a grain that's in
# a nested dictionary. This is why it's now flat.
# FIXME: Should use the specific exception for the file being unavailable
# to be opened.


def main():
    grains = {}
    grains['hedron.sporestack.hosted'] = False

    try:
        with open('/etc/sporestack/end_of_life') as fp:
            grains['hedron.sporestack.end_of_life'] = fp.read().splitlines()
    except Exception:
        pass

    if 'hedron.sporestack.end_of_life' in grains:
        grains['hedron.sporestack.hosted'] = True

    return grains
