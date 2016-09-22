/**
 * This defined resource creates a local check using a file resource on the client
 * Arguments :
 * - resource name = check name
 * - cache_time : *int*' defines how often the local check must be instanciated by the agent
 * - content : the check contents
 * - mk_checks_dir : the check_mk local checks directory, if not default
 */
 define omd::check_mk::localcheck(
   $check=$name,
   $cache_time=0, 
   $content,
   $mk_checks_dir='/usr/lib/check_mk_agent/local/'
 ){
  
  validate_integer($cache_time)
  
  $extra_dir="$cache_time" ? {
    '0' => '',
    /[0-9]+/ => "/${cache_time}",
    default => ''
  }
  
  #make sure we purge the check_mk local checks dir
  include omd::check_mk::localcheck::directory
  
  ensure_resource('file',"${mk_checks_dir}${extra_dir}",{ensure => directory})
  
  file { "${mk_checks_dir}${extra_dir}/${check}":
    ensure=>present,
    mode => '0755',
    content => $content
  }

  #add a tag, which will trigger an inventory too
  omd::check_mk::addtag{"${check}":}
} 
