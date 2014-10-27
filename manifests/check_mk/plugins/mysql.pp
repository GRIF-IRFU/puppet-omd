class omd::check_mk::plugins::mysql(
  $omd_sites=['all'],
) {
  
  file { "/usr/lib/check_mk_agent/plugins/mk_mysql":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/mysql/mk_mysql.agent",
  }
  omd::check_mk::addtag{ "MySQL": omd_sites=>$omd_sites }
}

define omd::check_mk::plugins::mysql::server(
  $site=$name,
 ) {
  file { "/opt/omd/sites/${site}/share/check_mk/checks/mysql":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/mysql/mysql.server",
  }
  file { 
  	"/opt/omd/sites/${site}/share/check_mk/pnp-templates/check_mk-mysql.innodb.php":
		owner   => root,
		group   => root,
		ensure  => file,
		mode    => 0655,
		source  => "puppet:///modules/omd/plugins/mysql/check_mk-mysql_status.php";

     "/opt/omd/sites/${site}/share/check_mk/pnp-templates/check_mk-mysql_capacity.php":
		owner   => root,
		group   => root,
		ensure  => file,
		mode    => 0655,
		source  => "puppet:///modules/omd/plugins/mysql/check_mk-mysql_capacity.php";

     "/opt/omd/sites/${site}/share/check_mk/pnp-templates/check_mk-mysql_slave.php":
		 owner   => root,
		group   => root,
		ensure  => file,
		mode    => 0655,
		source  => "puppet:///modules/omd/plugins/mysql/check_mk-mysql_slave.php";

  }
}
