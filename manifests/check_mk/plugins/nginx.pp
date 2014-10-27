class omd::check_mk::plugins::nginx(
  $omd_sites=['all'],
) {
  
  file { "/etc/check_mk/nginx_status.cfg":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/nginx/nginx_status.cfg",
  }

  file { "/usr/lib/check_mk_agent/plugins/nginx_status":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/nginx/nginx_status.agent",
  }
  omd::check_mk::addtag{ "Nginx": omd_sites=>$omd_sites }
}

define omd::check_mk::plugins::nginx::server(
  $site=$name,
 ) {
  file { "/opt/omd/sites/${site}/share/check_mk/checks/nginx_status":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/nginx/nginx_status.server",
  }
  file { "/opt/omd/sites/${site}/share/check_mk/pnp-templates/check_mk-nginx_status.php":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/nginx/check_mk-nginx_status.php",
  }
}
