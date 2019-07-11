#!/usr/bin/env python3

import sys


def main():
    grains = {}

    for path in sys.path:
        if '/usr/local/lib' in path:
            if 'dist-packages' in path:
                grains['hedron_python_dist_path'] = path
                return grains

    raise Exception('Unable to find correct dist-path for Python.')
