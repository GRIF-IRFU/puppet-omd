#!/bin/bash
# $* is the nrpe options
TMPF=`mktemp /tmp/mkout.XXXXXX` || exit 1
<%= @nrpe_plugin %> $* > $TMPF
RETCODE=$?
uudecode -o /dev/stdout $TMPF |bunzip2
rm -f $TMPF
exit $RETCODE