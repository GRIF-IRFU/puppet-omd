#this defined resource will add a plugin's *native* check_mk check onto the OMD server.
#
#the name will be by default used to search for that plugin under the omd odules files directory, eg. :
#  omd/files/plugins/<plugin>/
#
# default source file name will be : <resource_name>.py
# default target file name (the plugin agent file name) will be the resource name (without the .py) as the check_mk file must match the inventory name
define omd::check_mk::plugins::check(
  $sourcepath="puppet:///modules/omd/plugins/${name}/",
  $sourcefile="${name}.py",
  $destfile=$name,
  $ensure = 'present',
  $owner  = 'root',
  $group  = 'root',
  $destination = "/opt/omd/versions/default/share/check_mk/checks/", #it is *assumed* a check can be shared with all sites. If you want to define a check only for 1 site, use the site var
  $site = undef,
  ) {

  include ::omd::common::anchors
  include ::omd::common::folders

  $real_destination = $site ? {
    undef => $destination,
    default => "/opt/omd/sites/${site}/share/check_mk/checks/",
  }

  file { "${real_destination}/${destfile}" :
    ensure => $ensure,
    mode   => '0755',
    owner  => $owner,
    group  => $group,
    source => "${sourcepath}/${sourcefile}"
  }
  ->
  Anchor['checkmk_inventory']

}
