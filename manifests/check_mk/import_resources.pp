#
# Import_Resources. This is called only on the monitoring server and realises
# the resources from the above sections. 
#
# The resource title must be the OMD sitename
#
# The overall result is that:
#   We should get an appropriately named file in /etc/checkmk/conf.d/puppet/
#   "/usr/bin/cmk -I hostname" should be called to inventory the host
#   "/usr/bin/cmk -O" should be executed to rebuild the config
#
# If we remove a host from puppet (by running "puppet node clean --unexport" the
# hosts monitoring config should be neatly removed.
#
# 21/03/2014 - Update by F.SCHAER : 
#  since we're designing this for OMD, we need to ba able to use it as a defined resource,
#  and we need to be able to use the sitename to deduce the username and the pathname of
#  the various tools. 
#
#  One of the consequences is that we must add more tags to the exported resources, to be able 
#   to restrict (or not) exported resources to some OMD instances
define omd::check_mk::import_resources {
 
  #use the global /etc check_mk config global to all OMD sites :
  # I've tryed symlinking the global directory : this did not work , check_mk ignores symlinks...so we must rsync.
  file { "/opt/omd/sites/${name}/etc/check_mk/conf.d/omd-all" :
    ensure=> directory,
    owner => "${name}",
    require => Exec["omd create site ${name}"],
  } 
  ->
  exec { "sync omd-all with ${name}" :
    command => "rsync -a --delete /etc/check_mk/conf.d/omd-all/ /opt/omd/sites/${name}/etc/check_mk/conf.d/omd-all/",
    path => ['/usr/bin','/usr/sbin','/bin','/sbin',],
    user => "${name}",
    notify => Exec["checkmk_refresh_${name}"],
    refreshonly => true,
    subscribe => File['/etc/check_mk/conf.d/omd-all'],
  }
  -> Exec <| tag=='checkmk_inventory' |> #we cannot run the inventory before we have the configs
 
 
  #realize globally explorted resources for all umd sites (tag : all)
  # Realise all the file fragments exported from the monitored hosts
  File <<| tag == "checkmk_conf_all" |>> ~> Exec["sync omd-all with ${name}"]
  # in addition, each one will have a corresponding exec resource, used to re-inventory changes
  Exec <<| tag == "checkmk_inventory_all" |>> <- Exec["sync omd-all with ${name}"]
  
  #and realize resources exported only for this omd site, but do not duplicate resources already invotoried :
  #by not "duplicating", I mean : do not duplicate *nagios* resources. 
  File <<| tag == "checkmk_conf_${name}" and tag !="checkmk_conf_all" |>> ~> Exec["checkmk_refresh_${name}"]
  Exec <<| tag == "checkmk_inventory_${name}" and tag !="checkmk_inventory_all"  |>> ~> Exec["checkmk_refresh_${name}"]
  
}
