#!/usr/bin/python
from time import time
from yaml import load

# if your puppet has a different statefile, modify it here
#STATEFILE = "/var/lib/puppet/state/last_run_summary.yaml"
STATEFILE = "/opt/puppetlabs/puppet/cache/state/last_run_summary.yaml"

def main():
    print '<<<puppet>>>'
    print_puppet_state(STATEFILE)

def print_puppet_state(statefile):
    puppet_state = load(file(statefile, 'r'))
    last_run = int(time()) - puppet_state.get('time').get('last_run', 2000000000)
    print "%s %s %s %s" % (puppet_state.get('resources').get('changed', 0), puppet_state.get('resources').get('failed', 0), puppet_state.get('time').get('total', 0), last_run)
    

if __name__ == '__main__':
    main()
