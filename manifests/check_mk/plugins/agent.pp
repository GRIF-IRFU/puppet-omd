#this defined resource will add a plugin's agent part onto the checked nodes
#the name will be by default used to search for taht plugin under the omd odules files directory, eg. :
#  omd/files/plugins/<plugin>/
#
# default source file name will be : agent.sh
# default target file name (the plugin agent file name) will be the resource name
define omd::check_mk::plugins::agent(
  $sourcepath="puppet:///modules/omd/plugins/${name}/",
  $sourcefile="agent.sh",
  $destfile=$name,
  $ensure = 'present',
  $owner  = 'root',
  $group  = 'root',
  ) {

  include omd::common::folders
  file { "${omd::common::folders::agent_libdir}/plugins/${destfile}" :
    ensure => $ensure,
    mode   => '0755',
    owner  => $owner,
    group  => $group,
    source => "${sourcepath}/${sourcefile}"
  }
}
