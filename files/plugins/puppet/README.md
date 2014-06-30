cmk-puppet-status
=================

These are components which can monitor puppet client status from check_mk.

There are three files:

* check_puppet.py - a python script that will be run by check_mk-agent, and should be installed
           on any nodes which will be monitored.  This requires PyYAML, and the script itself goes
           in /usr/lib/check_mk_agent/plugins/check_puppet.py and must be executable.
           If your puppet state file is not in /var/lib/puppet/state/last_run_summary.yaml you must modify this script.
           As you are already using puppet, distribution of these things is left as an exercise to the reader :)

* puppet - the check_mk recipe to parse the output from the python script above. This resides on your nagios
           server in /usr/share/check_mk/checks/puppet

* perfometer_check_mk_puppet_status.py (optional) - a perfometer recipe for displaying the nifty in-line graph.
           This file typically goes in /usr/share/check_mk/web/plugins/perfometer/perfometer_check_mk_puppet_status.py

LICENSE

The lousy code in this repository is copyright 2012 by Jeremy Thornhill. It is placed in the public domain. So, knock yourself out!

USAGE

First, put those files where they belong.

Next, (optionally) configure your thresholds (in seconds) in check_mk - the variable name is "puppet_run_stats".
The default thresholds are 35 minutes (warning) and 65 minutes (crit).

Finally, when things are in place, run check_mk --checks=puppet.status -I; check_mk -R; service httpd restart

NOTES

Whatever user account runs your cmk agent script must have read access to your puppet state file (generally in 
/var/lib/puppet/state/last_run_summary.yaml ). You must have a not-ancient version of puppet for the state file to
be populated with the data this check requires (this is tested with clients as old as 2.6.9)

Services will go critical if any failures were reported in the run and/or if the freshness threshold is exceeded.

The perfometer will display different data depending on the run state. The issue is that perfometers are really bad at expressing
composite checks like this which have multiple data sources, but I also don't really want to give each metric of the puppet run its
own service check. I honestly don't totally love how this works, so please feel free to send me some feedback if you can think of a
better way to represent the data in perfometer form:

- no changes, no failures, within freshness threshold: green graph of run time as percentage of warn; text is minutes since last run
- some changes, no failures, within freshness threshold: magenta graph of run time as percentage of warn; text is number of changed resources
- some failures: red graph of run time as percentage of warn; text is number of failed resources
- no failures, freshness threshold exceeded: yellow (if warn) red (if crit) graph as percentage of warn; text is minutes since last run

If you are using pnp4nagios with check_mk (which you really should be doing) you'll get graphs of the data this plugin tracks (run time,
run freshness, failed resources, changed resources).


