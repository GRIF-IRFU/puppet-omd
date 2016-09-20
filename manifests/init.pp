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
  $omd_version='1.20', #or omd-1.11.20140328
  $omd_release=latest,
  $fix_v130bug=false, # fixes a bug, which gives an internal error 500
) {

  if($with_repo) {
    case $::osfamily {
      debian : { include omd::repos::debian }
      redhat : { include omd::repos::redhat }
      default : { fail("unsupported os family : $::osfamily")}
    }
  }

  case $::osfamily {
    debian : { $omd_service = "omd-$omd_version" }
    redhat : {
      if(0+$::operatingsystemmajrelease >= 6){
        require epel
      }
      $omd_service = "omd"

      # This is a bugfix for wrong python libraries in Centos 7.2 with omd 1.30
      if( $fix_v130bug ) {
        notify { 'workaround information':
          message => "The hashlib symlinks are being created as Workaround to a bug in omd Version 1.30",
        }
        file { '/opt/omd/versions/1.30/lib/python/hashlib.py':
          ensure => link,
          target => "/usr/lib64/python2.7/hashlib.py",
          require => Package['omd'],
        }
        file { '/opt/omd/versions/1.30/lib/python/hashlib.pyc':
          ensure => link,
          target => "/usr/lib64/python2.7/hashlib.pyc",
          require => Package['omd'],
        }
      }
    }
    default : { fail("unsupported os family : $::osfamily")}
  }
  
  package {"omd": name => "omd-$omd_version", ensure => $omd_release}
  ->
  service {'omd': name => "$omd_service", enable => true, ensure => running}

}
