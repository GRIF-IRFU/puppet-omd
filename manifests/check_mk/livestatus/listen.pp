/**
 * This makes xinetd listen on some port.
 * This can be defined for each site, but only if ports do not colide. Therefore, the port is what will be in the file resource name
 */
 
 define omd::check_mk::livestatus::listen(
   $site=$name,
   $port=6557,
   $only_from=[], #this is a list of hosts or ip addresses allowed to connect to the xinetd socket
 ) {
  file {"xinetd livestatus $port":
    path=>"/etc/xinetd.d/livestatus-${site}",
    mode => '644',
    content=>template('omd/livestatus.xinetd.erb'),
    notify=>Service[xinetd]
  }
 }
