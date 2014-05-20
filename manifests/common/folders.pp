/**
 * Creates folders that are shared between tools
 */
class omd::common::folders {
  @file { "/etc/check_mk":
      ensure  => directory,
      tag => 'check_mk_folder';
    "/etc/check_mk/conf.d":
      ensure=> directory,
      tag => 'check_mk_folder';
    "/etc/check_mk/conf.d/omd-all":
      purge   => true,
      recurse => true,
      ensure=> directory,
      tag => 'check_mk_folder',
  }
}
