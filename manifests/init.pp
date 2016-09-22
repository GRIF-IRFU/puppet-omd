/**
 * Base OMD installation : installas the package, and eventually configures the repository.
 *
 * Either use class parameters or hiera to change the defaults.
 *
 * NOTE : omd_version :
 *  - latest known to this module, as the OMD package name contains the version, this makes it impossible to just install "omd"
 *  - latest can still be used for the release, but not for the package name
 */
class omd(
  $with_repo=true,
  $omd_version='1.30', #or omd-1.11.20140328
  $omd_release=latest,
  $libdbi_release=latest,
  $basedir = undef, #defines another place where to put omd : a symlink in /opt/omd will point to this place in order to achieve omd relocation
) {


  if($with_repo) {
    case $::osfamily {
      'Debian': { include omd::repos::debian }
      'RedHat': { include omd::repos::redhat }
      default : { fail("unsupported os family : $::osfamily")}
    }
  }

  case $::osfamily {
    'Debian': {
      $omd_service = "omd-${omd_version}"
      $dbi_pkg = 'libdbi1'
      $svc_provider=undef
    }
    'RedHat': {
      $omd_service = 'omd'
      $dbi_pkg = 'libdbi'
      $svc_provider='init'
      if( 0+$::operatingsystemmajrelease >= 6 ) {
        require epel
      }
      # This is a bugfix for wrong python libraries in Centos 7.2 with omd 1.30
      # The hashlib symlinks are being created as Workaround to a bug in omd Version 1.30.
      # this bug disappeared with unstable version 1.31, and the workaround will be removed hopefully with omd 1.40
      # contribution from https://github.com/Melkor333
      if( $omd_version='1.30' and $::lsbdistdescription =~ /^CentOS Linux release 7.2/ ) {
        file { '/opt/omd/versions/1.30/lib/python/hashlib.py':
          ensure  => link,
          target  => "/usr/lib64/python2.7/hashlib.py",
          require => Package['omd'],
        }
        file { '/opt/omd/versions/1.30/lib/python/hashlib.pyc':
          ensure  => link,
          target  => "/usr/lib64/python2.7/hashlib.pyc",
          require => Package['omd'],
        }
      }
    }
    default : { fail("unsupported os family : $::osfamily")}
  }

  #include apache module
  include apache
  include apache::mod::ssl
  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::headers

  #change omd base installation if needed - and ensure basedir/omd exists
  if($basedir) {
    file { "${basedir}/omd":
      ensure=> directory,
      mode => '0755',
    }
    file { '/opt/omd' :
      ensure => symlink,
      target => "${basedir}/omd",
      before => Package['omd']
    }
  }

  package { 'libdbi': name => $dbi_pkg , ensure => $libdbi_release } #libdbi seems to be an un-specified omd package (RPM) dependency
  ->
  package {"omd": name => "omd-$omd_version", ensure => $omd_release}
  ->
  service {'omd': name => "$omd_service", enable => true, provider => $svc_provider , ensure => running }

}
