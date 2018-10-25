/**
 * Creates a site, and allows to override various aspects
 * 
 * This also create refreshonly instances of EXEC resources that can be used for stopping, then configuring, and finally restarting the OMD instance,
 * as many omd commands do require having the omd instance stopped before doing anything. And we cannot afford having stop and starts for every exec.
 * 
 * todo :  
 * 
  omd stop irfu
  omd config irfu set LIVESTATUS_TCP on
  omd start irfu
  
 */
define omd::site(
  $crontabs=true, #if set to true, the user/site will be allowed to run crontabs (normally the default). If not, disable crontabs
  $refresh_timeout=600, #the refresh timeout is very important, as reloading nagios can take ages
) {
  
  $omd_path="/opt/omd/sites/${name}"
  $puppet_dir="${omd_path}/puppetstate"
  
  exec { "omd create site ${name}":
    command => "omd create ${name}; omd start ${name}",
    path => '/usr/bin',
    creates => "/opt/omd/sites/${name}",
    tag => 'omd_create',
    require => Package['omd']
  }
  
  
  #define the config dir for globally exported resources (tag which does not include the omd sitename)
  include omd::check_mk::omd_common
  include omd::common::folders
  File <| tag=='check_mk_folder' |>
  
  #refreshonly check_mk reload
  exec { "checkmk_refresh_${name}":
    path => ['/usr/bin','/usr/sbin','/bin','/sbin',],
    command     => "su -l -c '/opt/omd/sites/${name}/bin/cmk -O' -s /bin/sh ${name}",
    refreshonly => true,
    require => Exec["omd create site ${name}"],
    tag => 'check_mk_refresh_site', #used to be notified of a global check_mk config change, requiring a reload
    timeout => $refresh_timeout,
  }
  
  #Refreshonly maintenance exec
  exec { "omd maintenance start site ${name}":
    command => "omd start ${name}",
    path => '/usr/bin',
    refreshonly => true,
  }
  exec { "omd maintenance stop site ${name}":
    command => "omd stop ${name}  || /bin/true ", #don't fail id the site is already off
    path => '/usr/bin',
    refreshonly => true,
  }
  
  #since it's likely we'll have numerous OMD things that will require refreshing the service (nad stopping before configuring), create a state dir
  file { "${puppet_dir}": ensure=> directory ,
    require => Exec["omd create site ${name}"]
  }
  
  #
  #enable/disable crontabs, and run the exec only once
  #
  #use a state file for notifying OMD
  $cronenable = $crontabs ? {
    false => "off",
    default => "on"
  }
  $cronfile="${puppet_dir}/cron.txt"
  file {$cronfile: 
    ensure=>present,
    notify => Exec["omd maintenance stop site ${name}"], 
    content => $cronenable,
  }  
  ~>
  exec { "omd crontab ${name}":
    command => "omd config ${name} set CRONTAB $cronfile > /dev/null 2>&1 || rm -f $cronfile",
    path => ['/usr/bin','/usr/sbin','/bin','/sbin',],
    require => Exec["omd maintenance stop site ${name}"], 
    notify => Exec["omd maintenance start site ${name}"],
    refreshonly => true,
  }
  
  #prepare user additions by creating the virtual user config file initialisation
  @omd::multisite::userinit { $name: }
  
  #define the puppet managed dir for this omd site, and refresh check_mk when necessary
  $mk_confdir = "/opt/omd/sites/${name}/etc/check_mk/conf.d/puppet"
  file { "$mk_confdir":
    ensure  => directory,
    purge   => true,
    recurse => true,
    owner   => $name,
    group   => $name, 
    notify  => Exec["checkmk_refresh_${name}"],
    require => Exec["omd create site ${name}"]
  }
}
