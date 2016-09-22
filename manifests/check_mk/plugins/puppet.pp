class omd::check_mk::plugins::puppet(
  $omd_sites=['all'],
) {
  
  $pyyaml_pkg=$::osfamily ? {
    'Debian' => 'python-yaml',
    default => 'PyYAML',
  }

  ensure_resource('package', $pyyaml_pkg, {} )
  
  file { "/usr/lib/check_mk_agent/plugins/check_puppet.py":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => '0655',
    source  => "puppet:///modules/omd/plugins/puppet/check_puppet.py",
    require => Package[$pyyaml_pkg],
  } 
  omd::check_mk::addtag{"puppet": omd_sites=>$omd_sites }
}
