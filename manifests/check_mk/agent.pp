/**
 * Installs and enables the check_mk agent via xinetd
 */
class omd::check_mk::agent (
  $ip_whitelist = undef,
  $port = '6556',
  $server_dir = '/usr/bin',
  $use_cache = false,
  $user = 'root',
  
  #
  #agent related variables (different from original source):
  #
  
  #add /usr/sbin to path
  $agent_path='$PATH:/usr/local/bin:/usr/sbin',
  
  #reduce ps output. On heavily loaded machines, the original ps output can be as big as 500KB
  $agent_ps_columns=200,
  
  #prevent the df checks from disabling autofs timeouts on fuse filesystems, ie on cvmfs for instance
  #format : -x <fstype> -x <fstype>...
  $agent_df_extra_excludes='-x fuse',
  
) {
  
  package { ['time']:
    ensure => present,
  }
  #setup directories:
  include omd::common::folders
  File <| title == '/etc/check_mk' |>
  file { ['/usr/lib/check_mk_agent', '/usr/lib/check_mk_agent/local', '/usr/lib/check_mk_agent/plugins', '/var/lib/check_mk_agent','/var/lib/check_mk_agent/job',]:
    ensure=>directory
  }
  
  #copy unmodified files
  file {
    '/usr/bin/mk-job': 
      ensure =>present,
      source => 'puppet:///modules/omd/check_mk/mk-job',
      mode => 755
    ;
    '/usr/bin/waitmax': 
      ensure =>present,
      source => 'puppet:///modules/omd/check_mk/waitmax',
      mode => 755
    ;
  }
  
  $only_from = $ip_whitelist ? {
    undef =>  undef,
    default => join($ip_whitelist, ' '),
  }
  
  
  #configure xinetd and notify the service if required by user.
  include xinetd
  file { '/etc/xinetd.d/check_mk':
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '0644',
    content => template('omd/check_mk.xinetd.erb'),
    notify => Service[xinetd],
  }
  
  #now, put modified check_mk_agent file.
  
  file { '/usr/bin/check_mk_agent':
    ensure =>present,
    content => template('omd/check_mk_agent.erb'),
    mode => 755
  }
  
}
