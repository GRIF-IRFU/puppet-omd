/**
 * This defines a legacy nagios service, using check_mk
 * 
 * The service description is the resource name by default, but beware this will be duplicated if using several omd sites.
 */
 
 define omd::check_mk::legacy::service (
   $site,
   
   #first member of a check_mk service definition is a triple : 
   $command,
   $description="${name}",
   $perfdata=false,
   
   #second optional arg is tags. Please give them as an array
   $mk_tags=undef,
   
   #third 'non-optional' arg is the hosts. But set ALL_HOSTS by default, this is usefull. Otherwise, please provide a list.
   $mk_hosts='ALL_HOSTS'
 ) {
   
  #make sure the legacy_checks variable exists before we can add something
  ensure_resource('omd::check_mk::var::set' , 'legacy_checks', { site=>"${site}", content=>'[]', cfgfile=>'services'} )
  
  #tags checks. If present, provide the config with an escaped python list and a ',' so that we can add the hosts
  $tags = $mk_tags ? {
    undef => undef,
    default => inline_template('[\'<%= @mk_tags.join("\',\'") %>\'] , ' )
  }

  #hosts checks
  $hosts = $mk_hosts ? {
    'ALL_HOSTS' => $mk_hosts,
    default => inline_template('[\'<%= @mk_hosts.join("\',\'") %>\']' )
  }
   
  #perfdata check
  $perfstr=$perfdata ? {
    false => 'False',
    default => 'True',  
  }
    
  #append to legacy_checks variable
  omd::check_mk::var::append{"legacy_checks|$description": site=>$site, cfgfile=>'services', content=> "[(('${command}','${description}',${perfstr}), ${tags} ${hosts} )]"}
   
 }
