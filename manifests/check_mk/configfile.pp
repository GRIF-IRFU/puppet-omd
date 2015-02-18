/**
 * Ensures a config file is present, and allows duplicate resource declaration
 * 
 * Please ommit the '.mk' from the filename
 */
 define omd::check_mk::configfile(
   $site,
   $filename=$name, #required in case there are 2 omd sites
   $component='check_mk', #this allows to define config files for other components. Currently, only multisite|check_mk is allowed
 ) {
  
  # multisite or check_mk ?
  $path = $component ? {
    'multisite' => 'multisite.d',
    default => 'conf.d/puppet'
  }
  
  #prepare custom user-specified check_mk configuration files (prepare the concat)
  # the user can then add any check_mk var user omd::check_mk::addvar
  concat{"check_mk_puppetvars_${site}_${filename}_${component}":
      owner => "${site}",
      group => "${site}",
      mode => '644',
      path => "/opt/omd/sites/${site}/etc/check_mk/${path}/${filename}.mk",
      require => Exec["omd create site ${site}"]
   }
   ->
   Exec <| tag == "checkmk_inventory" |>
   
   concat::fragment{"check_mk_puppetvars_${site}_${filename}_${component}_header":
      target => "check_mk_puppetvars_${site}_${filename}_${component}",
      content => "#\n# puppet-managed file. Do not edit\n#\n",
      order => "000",
   }
   ->
   Exec <| tag == "checkmk_inventory" |>
   
 }
