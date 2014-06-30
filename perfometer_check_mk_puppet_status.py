def perfometer_check_mk_puppet_status(row, check_command, perf_data):
    # these times are in seconds; we display them in minutes for clarity
    failed = int(perf_data[1][1])
    changed = int(perf_data[0][1])
    time = int(int(perf_data[2][1]) / 60)
    warn = int(int(perf_data[2][3]) / 60)
    crit = int(int(perf_data[2][4]) / 60)
    # if any failed, short circuit here and report # failed
    if failed >= 1:
        color = "#ff0000"
        limit = int(float(time) / float(warn) * 100)
        return "[%d FAILED]" % (failed, ), perfometer_linear(limit, color)
    # if we succeeded but time is over warning interval, report the time
    elif time >= crit:
        color = "#ff0000"
        limit = int(float(time) / float(warn) * 100)
    elif time >= warn:
        color = "#ffff00"
        limit = int(float(time) / float(warn) * 100)
    # if we succeeded with changes within interval, report the number of changes
    # (but still graph the last run freshness)
    elif changed >= 1:
        color = "#00FFFF"
        limit = int(float(time) / float(warn) * 100)
        return "[%d CHANGED]" % (changed, ), perfometer_linear(limit, color)
    # otherwise, no changes, no failures, just show the time since the prior run
    else:
        color = "#00ff00"
        limit = int(float(time) / float(warn) * 100)
    return "%d minutes" % (time, ), perfometer_linear(limit, color)

perfometers['check_mk-puppet.status'] = perfometer_check_mk_puppet_status
