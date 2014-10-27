class omd::check_mk::plugins::postgres(
  $omd_sites=['all'],
) {
  
  file { "/usr/lib/check_mk_agent/plugins/mk_postgres":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/postgres/mk_postgres.agent",
  }
  omd::check_mk::addtag{ "PostgreSQL": omd_sites=>$omd_sites }
}

define omd::check_mk::plugins::postgres::server(
  $site=$name,
 ) {
  file { 
  	"/opt/omd/sites/${site}/share/check_mk/checks/postgres_sessions":
	    owner   => root,
	    group   => root,
	    ensure  => file,
	    mode    => 0655,
	    source  => "puppet:///modules/omd/plugins/postgres/postgres_sessions.server";
	
	"/opt/omd/sites/${site}/share/check_mk/checks/postgres_stat_database":
	    owner   => root,
	    group   => root,
	    ensure  => file,
	    mode    => 0655,
	    source  => "puppet:///modules/omd/plugins/postgres/postgres_stat_database.server",	    
  }
}

