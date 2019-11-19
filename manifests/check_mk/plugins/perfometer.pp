#this defined resource will add a plugin's *native* check_mk check onto the OMD server.
#
#the name will be by default used to search for that plugin under the omd odules files directory, eg. :
#  omd/files/plugins/<plugin>/
#
# default source file name will be : <resource_name>.py
# default target file name (the plugin agent file name) will be named dollowing the resource name
define omd::check_mk::plugins::perfometer(
  $sourcepath="puppet:///modules/omd/plugins/${name}/",
  $sourcefile="perfometer.py",
  $destfile="${name}_perfometer.py",
  $ensure = 'present',
  $owner  = 'root',
  $group  = 'root',
  $site ,
  ) {

  include omd::common::folders

  $real_destination = "/opt/omd/sites/${site}/local/share/check_mk/web/plugins/perfometer"

  #we must refresh the check_mk site
  $real_notify = $site ? {
    undef => "check_mk_refresh_site",
    default => "checkmk_refresh_${site}"
  }

  file { "${real_destination}/${destfile}" :
    ensure => $ensure,
    mode   => '0755',
    owner  => $owner,
    group  => $group,
    source => "${sourcepath}/${sourcefile}"
  }
  ~>
  Exec <<| tag=="$real_notify" |>>


}
