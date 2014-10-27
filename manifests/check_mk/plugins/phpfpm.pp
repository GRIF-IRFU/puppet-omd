class omd::check_mk::plugins::phpfpm(
  $omd_sites=['all'],
) {
  
  file { "/usr/lib/check_mk_agent/local/check_phpfpm_status.pl":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/local/check_phpfpm_status.pl",
  }
  omd::check_mk::addtag{ "php-fpm": omd_sites=>$omd_sites }
}

