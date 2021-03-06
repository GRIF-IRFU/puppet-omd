#
# Build_Exported_Resources - This is where the config is actually generated.
#
# We define the config file fragment (from a template) and an exec that will inventory
# the host. It is important to note that, although these resources are created on the client,
# they are actually realised on the monitoring server.
#
# 25/04/2017 - github feature request - future parser compatibility (#27) : change the # default char of the allow_duplicated to accomodate puppet4/future parser
#
# 21/03/2014 - Update by F.SCHAER :
#  make the class OMD compliant, and use the users home dir as a base. The resource name is the omd site name
#
#  Since we want to be able to collect resources only for the exported omd site tag, we must allow this "class" to become a define
#   (in order to export things for each tag), and allow duplicate resources declaration. Here is the hack explained :
#   http://ttboj.wordpress.com/2013/06/04/collecting-duplicate-resources-in-puppet/

define omd::check_mk::build_exported_resources(
  $allow_duplicates = undef,
  $monitoring_network = undef,
  $brokendns = lookup('omd::brokendns',{ default_value => false })                     , # set to true if you want to hardcode ipadresses on the omd server...
  $use_cloud_public_ip = lookup('omd::user_cloud_public_ip',{ default_value => true }) , # set to false if your cloud instances do have DNS resolution from the omd server
) {

  #determine if host is a public cloud host
  $use_cloud_ip = $facts['ec2_metadata'] ? {
    undef => false,
    default => $use_cloud_public_ip
  }

  # a non empty string is true, and in puppet4, the emtpy string *also* is true (false in puppet3), hence base the decision on "undef or anything"
  if $allow_duplicates {
    # allow the user to specify a specific split string to use...
    $c = type3x($allow_duplicates) ? {
          'string' => "${allow_duplicates}",
          default => '_XxX_',
    }
    if "${c}" == '' {
          fail('Split character(s) cannot be empty!')
    }

    # split into $realname-$uid where $realname can contain split chars
    $realname = inline_template("<%= @name.rindex(@c).nil?? @name : @name.slice(0, @name.rindex(@c)) %>")
    $uid = inline_template("<%= @name.rindex(@c).nil?? '' : @name.slice(@name.rindex(@c)+@c.length, @name.length-@name.rindex(@c)-@c.length) %>")

    ensure_resource('omd::check_mk::build_exported_resources', "${realname}", { monitoring_network => $monitoring_network })
  } else { # body of the actual resource...
    tag('unique')
    $mk_confdir="${name}" ? {
      'all' => "/etc/check_mk/conf.d/omd-all",
      default => "/opt/omd/sites/${name}/etc/check_mk/conf.d/puppet"
    }

    if $::fqdn {
      $mkhostname = $::fqdn
    } else {
      $mkhostname = $::hostname
    }

    #if there is an amazon or openstack public IP, use it
    $cloud_ip = $facts.dig('ec2_metadata','public-ipv4')
    if $cloud_ip {
      $override_ip = $cloud_ip
    } else {
      #otherwise, attempt to find best IP probably using parameters passed to this resource (network/netmask)

      if "$monitoring_network" =~ /:/ {
        #monitoring network is ipv6
        $ip_bindings='bindings6'
      }
      elsif "$monitoring_network" =~ /\./ {
        #monitoring network is ipv4
        $ip_bindings='bindings'
      }
      else {
        #no monitoring network given
        $ip_bindings=undef
      }

      $override_ip = template('omd/monitoring_ipaddress.erb')

    }

    #if there is an IP override, use it for the check_mk inventory command :
    $inventory_ip_str = $override_ip ? {
      undef => '',
      ''    => '',
      default => "--fake-dns $override_ip"
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
        command     => "bash -c 'cd /opt/omd/sites ; for i in * ; do sudo -i -u \${i} bin/cmk $inventory_ip_str -I $mkhostname ; done'",
        path => ['/usr/bin','/usr/sbin','/bin','/sbin',],
        notify      => Exec["checkmk_refresh_${name}"],
        refreshonly => true,
        tag         => ["checkmk_inventory_${name}","checkmk_inventory"],
        require => Class['omd'],
        #onlyif      => "test -f $mk_confdir/$mkhostname.mk",
      }
    } else {
      @@exec { "checkmk_inventory_${mkhostname}_${name}":
        command     => "sudo -i -u ${name} /opt/omd/sites/${name}/bin/cmk $inventory_ip_str -I $mkhostname",
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

