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
  #package related params :
  Boolean         $with_repo=false,
  String          $pkg_basename ,  # this is the base name of the omd package. can be omd, omd-labs, check-mk-raw ... unfortunately, the omd repos are out of date :'(
  Stdlib::HTTPUrl $download_baseurl,
  Variant[String, Integer] $release,
  String          $version,
  String          $checksum=undef,
  String          $checksum_type,

  Optional[Stdlib::Unixpath] $pkg_creates = undef, #defines what directory is created by the package once installed. Used for "yum localinstall" (or apt) execs to prevent reinstallion failures
  Optional[Stdlib::Unixpath] $basedir = undef, #defines another place where to put omd : a symlink in /opt/omd will point to this place in order to achieve omd relocation
  Boolean         $disablestartup = false,

  #internally used for building pkg name/url
  String          $pkg_extension,
  Stdlib::Unixpath $puppet_pkg_cachedir = '/opt/puppetlabs/puppet/cache/client_data'
) {

  #how installation is managed :
  # - either you have your own repo : this is perfect, and much easier : the package type is used for install
  # - or : download the requested omd version, then use the package manager for a "localinstall"
  # $pkg_name represents either the yum/apt whatever package to install, or the physical file that's downloaded
  #
  # there are issues with at least with the yum puppet provider, which tries to reinstall a local file over and over, and fails with a "nothing to do" error, so an exec is necessary to complete the install.
  #
  # Consol.labs repo are still available, but not setup now.
  if($with_repo) {

    $pkg_source = undef
    $pkg_name = "$pkg_basename-$version-$release"

    anchor {'before_omd_install':}
    ->
    package {"omd":
      name => $pkg_name ,
      ensure => 'present',
    }
    ->
    anchor{'after_omd_install':}

  } else {

    case $::osfamily {
      'Debian' : {
        # https://checkmk.com/support/1.6.0p6/check-mk-raw-1.6.0p6_0.buster_amd64.deb
        $pkg_name="$pkg_basename-${version}_${release}_${facts[os][architecture]}"
        $install_cmd = "/usr/bin/apt-get -q -y install"
      }

      'RedHat' : {
        #redhat and others : https://checkmk.com/support/1.6.0p6/check-mk-raw-1.6.0p6-el8-38.x86_64.rpm
        $pkg_name="$pkg_basename-$version-$release.${facts[os][architecture]}"
        $install_cmd = "/usr/bin/yum -d 0 -e 0 -y install"
      }

      default : { fail("unsupported os family : $::osfamily")}
    }

    $pkg_source    = "$download_baseurl/$version/$pkg_name"
    $pkg_filepath  = "$puppet_pkg_cachedir/$pkg_name.$pkg_extension"

    #download the package, then install :
    archive { "$pkg_filepath" :
      source => $pkg_source,
      checksum => $checksum,
      checksum_type => $checksum_type,
      checksum_verify => $checksum ? { undef => false, default => true },
    }
    ->
    anchor {'before_omd_install':}
    ->
    exec { "omd install" :
      command => "$install_cmd $pkg_filepath",
      creates => $pkg_creates,
    }
    ->
    anchor{'after_omd_install':}
  }

  case $::osfamily {
    'Debian': {
      $omd_service = "omd-${omd_version}"
    }
    'RedHat': {
      $omd_service = 'omd'
      require epel
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
      before => Anchor['before_omd_install']
    }

  }

  #the package resource will either use a package "real name" or a local downloaded file if not using the repos
  Anchor['after_omd_install']
  ->
  service {'omd': name => "$omd_service", enable => $disablestartup ? { true => false, default => true }, ensure => $disablestartup ? { true => 'stopped', default => 'running' } }

}
