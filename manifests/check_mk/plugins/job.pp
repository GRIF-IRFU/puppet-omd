class omd::check_mk::plugins::job(
  $omd_sites=['all'],
) {
  
 file {     '/usr/bin/mk-job': 
      ensure =>present,
      source => 'puppet:///modules/omd/check_mk/mk-job',
      mode => 755
  }
}

define omd::check_mk::plugins::job::server(
  $site=$name,
 ) {
  file { "/opt/omd/sites/${site}/share/check_mk/checks/job":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/job/job.server",
  }
  file { "/opt/omd/sites/${site}/share/check_mk/web/plugins/check_mk-job.php":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/job/check_mk-job.php",
  }
}
