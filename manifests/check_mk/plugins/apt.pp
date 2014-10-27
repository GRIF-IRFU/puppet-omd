class omd::check_mk::plugins::apt(
  $omd_sites=['all'],
) {
  
  file { "/usr/lib/check_mk_agent/plugins/check_apt.py":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/apt/check_apt.py",
  }
  omd::check_mk::addtag{ "apt": omd_sites=>$omd_sites }
}

define omd::check_mk::plugins::apt::server(
  $site=$name,
 ) {
  file { "/opt/omd/sites/${site}/share/check_mk/checks/apt":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/apt/check_apt",
  }
}
