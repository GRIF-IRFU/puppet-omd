/**
 * This allows the user to append to arbitrary variables in the check_mk configuration.
 * This will use a concat file
 * 
 * This resource will add a configuration file to an OMD site, and thus will require this site to be setup before it can be applied.
 * 
 * Resource name is the variable name, to which a subvar and an index can be appended (in that order) .
 * 
 * The subvar must be delimited with a '#'
 * The index must be delimited with a '|'
 * Anything after a '%' will be stripped off to allow for non-dupliucate resource names
 * 
 * Argument description :
 * - omd_site : required, this is the site where the variable will be setup
 * - content  : this is the variable content. Required. Please don't specify the openning and closing python brakets.
 * - cfgfile  : this is the config file *name* to use. By default, use the global config file. These files will be located under conf.d/puppet/ . Any non standard char will be stripped.

 * Example usage: 

 * Appending to a var :
 * omd::check_mk::append {ignored_checktypes: site=>'test', content=>'["if64" ,"nfsmounts"]'}
 * omd::check_mk::append {'ignored_checktypes|1': site=>'test', content=>'["ipmi_sensors"]'}
 * 
 */
define omd::check_mk::var::append(
  $site,
  $content,
  $concat_order=20,
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
  
  $content_hash=md5($content) #maybe this can proove to heavy on puppet master...
  
  #strip anything after the comment char "%".
  $varname=regsubst($name,'%.*','')
  
  #find if there is an index in the resource name.
  # did not find how to split a string and force at most N elements to be returned, so : replace a | with something improbable to be user-defined, then split on that
  
  $split_i='%___%__%_%'
  $array_i=split(regsubst($varname,'\|',$split_i),$split_i)
  
  $increment=$array_i[1] ? {
    undef=>0,
    /^[0-9]+$/ => "$array_i[1]",
    default => inline_template('<%= @array_i[1].sum %>') #make sure an increment "string" is converted to an integer increment
  }
  
  validate_re("$increment", "^[0-9]+$")
  $real_concat_order=$concat_order + $increment
  
  #find if there is a subvar :
  # did not find how to split a string and force at most N elements to be returned, so : replace a # with something improbable to be user-defined, then split on that
  $split_tag='#___#__#_#'
  $array_name=split(regsubst($array_i[0],'#',$split_tag),$split_tag)
  
  
  
  $subvar= $array_name[1] ? {
    undef => undef,
    default => $array_name[1]
  }
  
  $var_str=$subvar ? {
    undef => "${array_name[0]} +=",
    default => "${array_name[0]}['${subvar}'] +=",
  }
  

  concat::fragment{"check_mk_puppetvars_${site}_${array_name[0]}_${content_hash}":
      target => "check_mk_puppetvars_${site}_${config}_${comp}",
      content => "${var_str} $content\n",
      order => "${real_concat_order}",
      notify => Exec["checkmk_refresh_${site}"]
  }
  ->
  Exec <| tag == "checkmk_inventory" |>
  
}
