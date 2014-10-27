class omd::check_mk::plugins::nfsexports(
  $omd_sites=['all'],
) {
  
  file { "/usr/lib/check_mk_agent/plugins/nfsexports":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/nfsexports/nfsexports.agent",
  }
  omd::check_mk::addtag{ "nfsexports": omd_sites=>$omd_sites }
}

define omd::check_mk::plugins::nfsexports::server(
  $site=$name,
 ) {
  file { "/opt/omd/sites/${site}/share/check_mk/checks/nfsexports":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/nfsexports/nfsexports.server",
  }
}
