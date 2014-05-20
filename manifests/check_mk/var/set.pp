/**
 * This allows the user to add arbitrary variables to the check_mk configuration.
 * This will use a concat file
 * This will only set variables, and eventually set a subvariable of this variable. 
 * 
 * 
 * This resource will add a configuration file to an OMD site, and thus will require this site to be setup before it can be applied.
 * 
 * Resource name is the variable name
 * If the resource name contains a '#', then the remainder of the resource name is assumed to be a subvar to which the resource contents must be affected
 * 
 * Argument description :
 * - site : required, this is the site where the variable will be setup
 * - content  : this is the variable content. Required. Please don't specify the openning and closing python braces.
 * - cfgfile  : this is the config file *name* to use. By default, use the global config file. These files will be located under conf.d/puppet/ . Any non standard char will be stripped.
 * Example usage: 
 * 
 * 
 * omd::check_mk::set {: site=>'test', var=> 'ignored_checktypes', operator=> '+=', content=>'"if64" ,"nfsmounts"'}
 * 
 * 
 */
define omd::check_mk::var::set(
  $site,
  $variable=$name, #the variable name can be overriden to overcome puppet limitation for unqiue defined resource names, in case of multi-site omd
  $content,
  $concat_order='010',
  $cfgfile=undef,
  $component='check_mk', #this allows to define config files for other components. Currently, only multisite|check_mk is allowed
) {
  
  $config=$cfgfile ? {
    undef => 'global',
    default => regsubst($cfgfile,'[^a-zA-Z0-9.-_]','','G')
  }
  
  # multisite or check_mk ?
  $comp = $component ? {
    'multisite' => 'multisite',
    default => 'check_mk'
  }
  
  #ensure the config file exists
  ensure_resource('omd::check_mk::configfile', "${config}_${site}_${comp}" , {site=>$site, filename=>$config, component => $comp})
  
  #find if there is a subvar :
  # did not find how to split a string and force at most N elements to be returned, so : replace a # with something improbable to be user-defined, then split on that
  $split_tag='#___#__#_#'
  $array_name=split(regsubst($variable,'#',$split_tag),$split_tag)
  
  $subvar= $array_name[1] ? {
    undef => undef,
    default => $array_name[1]
  }
  
  $var_str=$subvar ? {
    undef => "${array_name[0]} =",
    default => "${array_name[0]}['${subvar}'] =",
  }
  
  #$content_hash=md5($content) #maybe this can proove to heavy on puppet master...

  concat::fragment{"check_mk_puppetvars_${site}_${array_name[0]}_${subvar}":
      target => "check_mk_puppetvars_${site}_${config}_${comp}",
      content => "${var_str} $content\n",
      order => $concat_order,
      notify => Exec["checkmk_refresh_${site}"]
  }
  ->
  Exec <| tag == "checkmk_inventory" |>
  
}
