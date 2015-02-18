/**
 * User define that allows to manually add hosts to check_mk 
 * The resource name is the user name
 * 
 * Anything after a "%" will be tripped off, this will enable the same host to be defined on different omd sites
 */
 
define omd::check_mk::addhost(
  $site,           #the OMD site to configure. If "all", then configures the host for all OMD sites.
  $hostname=$name, #the hostname if different from resource name
  $tags='userdefined',  #eventual tags to put on host. This is a string, not an array.
) {
  
  #strip anything after the comment char "%".
  $hname=regsubst($hostname,'%.*','')
  
  #make sure common folder exists
  include omd::common::folders
  File <| title == '/etc/check_mk/conf.d/omd-all' |>
  
  #define where to put host definition
  $omd_path = $site ? {
    'all' => '/etc/check_mk/conf.d/omd-all',
    default => "/opt/omd/sites/${site}/etc/check_mk/conf.d/puppet"
  }
  
  #merge host tags
  #$htags=join($tags,'|') #this fails on non-array params :'(
  $htags=$tags
  
  #now, create the host.
  file { "${omd_path}/${hname}.mk":
    ensure=>present,
    owner => "${site}",
#    content => "ipaddresses['wn274.datagrid.cea.fr'] = '192.54.207.164'
    content => "all_hosts += ['${hname}|${htags}']\n",
    require => Exec["omd create site ${site}"]
  }
  ~>
  Exec["checkmk_inventory_${hname}_${site}"]
  
  
  #create the exec for the inventory
  if("${name}" == "all") {
      exec { "checkmk_inventory_${hname}_${site}":
        command     => "bash -c 'cd /opt/omd/sites ; for i in * ; do sudo -i -u \${i} bin/cmk -I $hname ; done'",
        path => ['/usr/bin','/usr/sbin','/bin','/sbin',],
        notify      => Exec["checkmk_refresh_${site}"],
        refreshonly => true,
        tag         => ["checkmk_inventory_${site}","checkmk_inventory"],
        require => Class['omd'],
        #onlyif      => "test -f $mk_confdir/$mkhostname.mk",
      }  
    } else {
      exec { "checkmk_inventory_${hname}_${site}":
        command     => "su -l -c '/opt/omd/sites/${site}/bin/cmk -I $hname' -s /bin/sh ${site}",
        path => ['/usr/bin','/usr/sbin','/bin','/sbin',],
        notify      => Exec["checkmk_refresh_${site}"],
        refreshonly => true,
        tag         => ["checkmk_inventory_${site}","checkmk_inventory"],
        require => Exec["omd create site ${site}"],
      }  
    }
}
