define omd::check_mk::server::plugins::puppet(
  $site=$name,
 ) {
  file { "/opt/omd/sites/${site}/share/check_mk/checks/puppet":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => '0655',
    source  => "puppet:///modules/omd/plugins/puppet/puppet",
    require => Exec["omd create site ${site}"]
  }
  file { "/opt/omd/sites/${site}/share/check_mk/web/plugins/perfometer_check_mk_puppet_status.py":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => '0655',
    require => Exec["omd create site ${site}"]
  }
}
