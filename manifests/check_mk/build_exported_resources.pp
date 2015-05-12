#
# Build_Exported_Resources - This is where the config is actually generated.
#
# We define the config file fragment (from a template) and an exec that will inventory
# the host. It is important to note that, although these resources are created on the client,
# they are actually realised on the monitoring server.
#
# 21/03/2014 - Update by F.SCHAER : 
#  make the class OMD compliant, and use the users home dir as a base. The resource name is the omd site name
#
#  Since we want to be able to collect resources only for the exported omd site tag, we must allow this "class" to become a define 
#   (in order to export things for each tag), and allow duplicate resources declaration. Here is the hack explained :
#   http://ttboj.wordpress.com/2013/06/04/collecting-duplicate-resources-in-puppet/

define omd::check_mk::build_exported_resources(
  $allow_duplicates = false,
  $monitoring_network = undef,
  $monitoring_netmask = undef
) {
  if $allow_duplicates { # a non empty string is also a true
    # allow the user to specify a specific split string to use...
    $c = type3x($allow_duplicates) ? {
          'string' => "${allow_duplicates}",
          default => '#',
    }
    if "${c}" == '' {
          fail('Split character(s) cannot be empty!')
    }

    # split into $realname-$uid where $realname can contain split chars
    $realname = inline_template("<%= @name.rindex('${c}').nil?? @name : @name.slice(0, @name.rindex('${c}')) %>")
    $uid = inline_template("<%= @name.rindex('${c}').nil?? '' : @name.slice(@name.rindex('${c}')+'${c}'.length, @name.length-@name.rindex('${c}')-'${c}'.length) %>")

    ensure_resource('omd::check_mk::build_exported_resources', "${realname}", { monitoring_network => $monitoring_network , monitoring_netmask => $monitoring_netmask })
  } else { # body of the actual resource...
    tag('unique')
    $mk_confdir="${name}" ? {
      'all' => "/etc/check_mk/conf.d/omd-all",
      default => "/opt/omd/sites/${name}/etc/check_mk/conf.d/puppet"
    }
    
    $checkmk_no_resolve = true
     
    if $::fqdn {
      $mkhostname = $::fqdn
    } else {
      $mkhostname = $::hostname
    }
    
    #if there is an amazon public IP, use it
    if $::ec2_public_ipv4 {
      $override_ip = $ec2_public_ipv4
    } else {
      #otherwise, attempt to find best IP probably using parameters passed to this resource (network/netmask)
      $override_ip_tmp = template('omd/monitoring_ipaddress.erb')
      $override_ip = $override_ip_tmp ? {
        '' => $::ipaddress,
        undef => $::ipaddress,
        default => $override_ip_tmp
      } 
    }
    
    
    
    # Running 'puppet node clean --unexport <node name="">'
    # on the puppet master will cause these resources to be cleanly
    # removed from the check_mk server.
   
    # the exported file resource; the template will create a valid snippet
    # of python code in a file named after the host
    @@file { "$mk_confdir/$mkhostname.mk":
        content => template("omd/collection.mk.erb"),
        notify  => Exec["checkmk_inventory_${mkhostname}_${name}"],
        tag     => ["checkmk_conf_${name}",'check_mk_exported_data'],
    }
    
    #special case : the tag is "all", we must then loop on every omd site and tell it to refresh its inventory for this node, and we must do a sudo for this to work.
    #this is the omd specificity to be able to run multiple instances that makes this over-complicated
    if("${name}" == "all") {
      @@exec { "checkmk_inventory_${mkhostname}_${name}":
        command     => "bash -c 'cd /opt/omd/sites ; for i in * ; do sudo -i -u \${i} bin/cmk -I $mkhostname ; done'",
        path => ['/usr/bin','/usr/sbin','/bin','/sbin',],
        notify      => Exec["checkmk_refresh_${name}"],
        refreshonly => true,
        tag         => ["checkmk_inventory_${name}","checkmk_inventory"],
        require => Class['omd'],
        #onlyif      => "test -f $mk_confdir/$mkhostname.mk",
      }  
    } else {
      @@exec { "checkmk_inventory_${mkhostname}_${name}":
        command     => "sudo -i -u ${name} /opt/omd/sites/${name}/bin/cmk -I $mkhostname",
        path => ['/usr/bin','/usr/sbin','/bin','/sbin',],
        notify      => Exec["checkmk_refresh_${name}"],
        refreshonly => true,
        tag         => ["checkmk_inventory_${name}","checkmk_inventory"],
        onlyif      => "test -f $mk_confdir/$mkhostname.mk",
        require => Exec["omd create site ${name}"],
      }  
    }
  }
}

