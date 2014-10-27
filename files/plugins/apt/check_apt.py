#!/bin/bash

if [[ -e /etc/debian_version && `which apt-get` ]] &>/dev/null ; then
    cache_time_ref=/var/cache/apt/pkgcache.bin
    delta=0

    # Only try to manually update the cache, if cron-apt is not installed.
    if [[ `dpkg-query -W -f='${Status}\n' cron-apt` != "install ok installed" ]] &>/dev/null ; then
        cache_time_ref=/var/cache/apt/pkgcache.bin
        now=`date +%s`
        mtime=`stat -c %Y $cache_time_ref`
        delta=$((now - mtime))

        if [[ $delta -gt 28800 ]] ; then
            /usr/bin/apt-get update &>/dev/null
            if [ $? -eq 0 ]; then
                /usr/bin/touch $cache_time_ref
            fi
            delta=0
        fi
    fi

    echo "<<<apt>>>"
    echo $delta
    cat /etc/debian_version
    waitmax 25 /usr/bin/apt-get -o Debug::NoLocking=yes -s dist-upgrade -y | awk '/^Inst/ { print $2 " " $5}' || echo "timeout_apt_get Debian-Security:X.X/DUMMY)"
fi
