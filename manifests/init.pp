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
    redhat : { $omd_service = "omd" }
    default : { fail("unsupported os family : $::osfamily")}
  }
  
  package {"omd": name => "omd-$omd_version", ensure => $omd_release}
  ->
  service {'omd': name => "$omd_service", enable => true, ensure => running}
  
}
