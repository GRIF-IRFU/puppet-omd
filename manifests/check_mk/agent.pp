/**
 * Installs and enables the check_mk agent via xinetd
 */
class omd::check_mk::agent (
  $ip_whitelist = undef,
  $port = '6556',
  $server_dir = '/usr/bin',
  $use_cache = false,
  $user = 'root',
  $template='omd/check_mk_agent.1.6.0p5.erb',

  #
  #agent related variables (different from original source):
  #

  #add /usr/sbin to path
  $agent_path='$PATH:/usr/local/bin:/usr/sbin:/usr/lib64/nagios/plugins:/usr/lib/nagios/plugins',

  #reduce ps output. On heavily loaded machines, the original ps output can be as big as 500KB
  $agent_ps_columns=200,

  #prevent the df checks from disabling autofs timeouts on fuse filesystems, ie on cvmfs for instance
  #format : -x <fstype> -x <fstype>...
  $agent_df_extra_excludes='-x fuse',

) {

  #setup directories:
  include omd::common::folders
  include omd::check_mk::localcheck::directory
  File <| title == '/etc/check_mk' |>

  #copy unmodified files
  file {
    '/usr/bin/mk-job':
      ensure =>present,
      source => 'puppet:///modules/omd/check_mk/mk-job',
      owner => 0,
      group => 0,
      mode => '0755'
    ;
    '/usr/bin/waitmax':
      ensure =>present,
      source => 'puppet:///modules/omd/check_mk/waitmax',
      mode => '0755',
      owner => 0,
      group => 0,
    ;
  }

  $only_from = $ip_whitelist ? {
    undef =>  undef,
    default => join($ip_whitelist, ' '),
  }


  #configure xinetd and notify the service if required by user.
  include ::xinetd

  File <| tag == 'check_mk_agent' |>
  ->
  file { '/etc/xinetd.d/check_mk':
    ensure => 'present',
    owner => 'root',
    group => 'root',
    mode => '0644',
    content => template('omd/check_mk.xinetd.erb'),
    notify => Service['xinetd'],
  }

  #put modified check_mk_agent file.
  file { '/usr/bin/check_mk_agent':
    ensure  => 'present',
    content => template($template),
    mode    => '0755',
    tag => 'check_mk_agent'
  }

  #also copy the caching agent
  file { '/usr/bin/check_mk_caching_agent':
    ensure  => 'present',
    source => 'puppet:///modules/omd/check_mk/check_mk_caching_agent',
    mode    => '0755',
    tag => 'check_mk_agent'
  }
}
