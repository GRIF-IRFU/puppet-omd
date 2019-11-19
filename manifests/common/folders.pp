/**
 * Creates folders that are shared between tools
 */
class omd::common::folders(
  $agent_libdir='/usr/lib/check_mk_agent',
  $agent_vardir='/var/lib/check_mk_agent',
) {
  @file { "/etc/check_mk":
      ensure  => directory,
      tag => 'check_mk_folder';
    "/etc/check_mk/conf.d":
      ensure=> directory,
      tag => 'check_mk_folder';
    "/etc/check_mk/conf.d/omd-all":
      purge   => true,
      recurse => true,
      force => true,
      ensure=> directory,
      tag => 'check_mk_folder',
  }

  file { ["$agent_libdir","${agent_libdir}/plugins", "$agent_vardir", "${agent_vardir}/job"] :
    ensure=>directory ,
    owner => root,
    group => root,
    mode  => '0755',
  }
}
