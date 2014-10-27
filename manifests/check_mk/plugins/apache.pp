class omd::check_mk::plugins::apache(
  $omd_sites=['all'],
) {
  
  file { "/etc/check_mk/apache_status.cfg":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/apache/apache_status.cfg",
  }

  file { "/usr/lib/check_mk_agent/plugins/apache_status":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/apache/apache_status.agent",
  }
  omd::check_mk::addtag{  "Apache": omd_sites=>$omd_sites }
}

define omd::check_mk::plugins::apache::server(
  $site=$name
 ) {
  file { "/opt/omd/sites/${site}/share/check_mk/checks/apache_status":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/apache/apache_status.server",
  }
  file { "/opt/omd/sites/${site}/share/check_mk/pnp-templates/check_mk-apache_status.php":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/apache/check_mk-apache_status.php",
  }
}
