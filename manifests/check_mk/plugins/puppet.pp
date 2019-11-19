class omd::check_mk::plugins::puppet(
  $omd_sites=['all'],
) {

  $pyyaml_pkg=$::osfamily ? {
    'Debian' => 'python-yaml',
    'RedHat' => $facts['os']['release']['major'] ? {
      '8' => 'python2-pyyaml',
      default => 'PyYAML'
    },
    default => 'PyYAML',
  }

  ensure_resource('package', $pyyaml_pkg, {} )

  file { "/usr/lib/check_mk_agent/plugins/check_puppet.py":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => '0755',
    source  => "puppet:///modules/omd/plugins/puppet/check_puppet.py",
    require => Package[$pyyaml_pkg],
  }
  omd::check_mk::addtag{"puppet": omd_sites=>$omd_sites }
}
