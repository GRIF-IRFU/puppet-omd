puppet-omd
==========

An open monitoring distribution (OMD) puppet configuration module

This module is intended to configure, install and manage an OMD distribution.

If required, this will use  the omd repository. 
This is the the default behaviour, so if you're managing your repos, make sure to disable this.
Last note concerning directories and packages : Othe omd packages do contain the OMD version in the package name : this makes it difficult to have a module that works out of the box and does not hardcode a specific version. We'll try to maintain this hardcoded version, but in case you need something else, please just use the omd_version class param in the omd class. Or give us a recipe to improve that ;)

This module borrows files from check_mk for the agent setup : those file license is under manifests/check_mk/agent

## How to use the server side
------------------------------

#### Install and start OMD :

    include omd

#### If you don't want the offical repositories to be setup (your have your own) :

    class {omd: with_repo => false}

#### create an OMD site which will be available on http://<your hostname>/<sitename>:

    omd::site {'test': }
    
#### create another OMD site on the same machine

    omd::site {'irfu': }


This will install the 'test' site and change the default http (htaccess) password for the user 

#### Add a multisite remote ... site/nagios/livestatus
    
    omd::check_mk::multisite::site { 'remotehost.example.org': site => 'irfu', alias=>'remote1' }

#### Remove the default OMD user :

The % char actually tells the defined resource to strip everything after it, so that the omdadmin user, which is the real username can be used for both OMD sites.
This unfortunately is required because of puppet not allowing duplicate defined resources titles

    omd::site::user {'omdadmin': site=>'test', ensure=>absent}
    omd::site::user {'omdadmin%2': site=>'irfu', ensure=>absent} 
  
    
#### Add a custom user

This use will be added with a custom password to the htaccess and given admin rights in multisite (password : "changeme")

    omd::site::user {'irfu': site=>'irfu', privileges=>'admin', pass_md5=>'HVSJ.h631LfUw'} 

#### Enable access over SSL/https for the omd users :

Please note this requires you manage the apache module with -say- puppetlabs-apache

    class { omd::ssl::vhost: sites=>[test], port => 443}

#### import all exported resources 

This will import everything for the OMD site irfu + all globally explorted resources

    omd::check_mk::import_resources{'irfu':}


####Create custom check_mk variables 

they are added before any inventory action, but beware that some variables only influence further inventories

    omd::check_mk::var::set    {ignored_checktypes: site=>'test', content=>'[ "ipmi_sensors", "if", "if64" ,"nfsmounts"]'}
    omd::check_mk::var::append {ignored_checktypes: site=>'test', content=>'["ipmi"]'}
    omd::check_mk::var::set {inventory_df_exclude_fs: site=>'test', content=>'["nfs", "fuse"]'}
    omd::check_mk::var::set {'filesystem_default_levels#levels': site=>'test', content=>'(80, 90)'}
    omd::check_mk::var::set {'filesystem_default_levels#levels_low': site=>'test', content=>'(60,75)'}
    omd::check_mk::var::set {'filesystem_default_levels#magic': site=>'test', content=>'0.5' }
    omd::check_mk::var::set {'ntp_default_levels': site=>'test', content=>'(10, 200.0, 1000.0)'}
    
check parameters...

    #FS check
    omd::check_mk::var::set    {check_parameters:     site=>'test', content=>'[( (85,90,0.5),   ALL_HOSTS, [ "fs_/var","fs_/tmp","fs_/home",])]'}
    omd::check_mk::var::append {'check_parameters|1': site=>'test', content=>'[( (90,95,1)  ,   ALL_HOSTS, [ "fs_/$",])]'}
    
    #specific setup for wn /var
    omd::check_mk::var::append {'check_parameters|2': site=>'test', content=>'[( (90,95,0.5), [ "wn", ], ALL_HOSTS, [ "fs_/var"])]'}
    
    #MEMORY usage over 110/150% of RAM
    omd::check_mk::var::append {'check_parameters|3': site=>'test', content=>'[( (110.0, 150.0),ALL_HOSTS, [ "mem.used",] )]'}
    
    #don't use the deprecated network check
    omd::check_mk::var::set {linux_nic_check: site=>'test', content=>'"lnx_if"'}
    
Performance data...

    #these are related, so make sure the first one is created before the second one
    omd::check_mk::var::set {'_disabled_graphs': site=>'test', content=>'["fs_","Kernel","NTP","Number of threads","Uptime"]' , concat_order=> '009'}
    omd::check_mk::var::set {"extra_service_conf#process_perf_data": site=>'test', content=>'[ ( "0", ALL_HOSTS, _disabled_graphs ), ]'}
  
host groups

    omd::check_mk::var::set    {define_hostgroups:     site=>'test', content=>"'true'"} 
    omd::check_mk::var::set    {host_groups:     site=>'test', content=>"[( 'wn', [ 'wn' ], ALL_HOSTS )]"} #association des tags à des hostgroups
    omd::check_mk::var::append {'host_groups|1': site=>'test', content=>"[( 'se', [ 'dpm_disk' ], ALL_HOSTS )]"}
    omd::check_mk::var::append {'host_groups|2': site=>'test', content=>"[( 'se', [ 'dpm_head' ], ALL_HOSTS )]"}
    omd::check_mk::var::append {'host_groups|3': site=>'test', content=>"[( 'other', [ '!wn', '!dpm_disk' ], ALL_HOSTS )]"}

Manually add hosts to the config :
  
    omd::check_mk::addhost{'10.2.5.8': site=> test, tags=>'snmp|Xtreme|BD-8810'}
    
append to arbitrary var

    omd::check_mk::var::set {'_toto': site=>'test', content=>'{"a" : 1}' }
    omd::check_mk::var::append {'_toto#a|1': site=>'test', content=>'1' }

Add host static aliases

    # we have to set the variable empty first, in order to avoid breaking check_mk - until it's used, it does not exist and we can't append.
    # or we could set it for the forst host, and append for others.
    # or we could set everything in one line (or not) 
    omd::check_mk::var::set {'extra_host_conf#alias': site=>'test', content=>'[]' }
    omd::check_mk::var::append {'extra_host_conf#alias|1': site=>'test', content=>'[("myalias" , ["my real hostname"])]' }    
    
create a nagios service adding it to host tags

    omd::check_mk::legacy::service {'ldap': site=>     'irfu', command =>'check_tcp!2170', mk_tags=>['ce','cream','dpm_head','bdii'], perfdata=>true}

create a nagios service adding it to a specific host

    omd::check_mk::legacy::service {'backbone': site=> 'irfu', command =>'check_snmp!-P 2c -C public -o ifHCInOctets.3003,ifHCOutOctets.3003 -u InBytes,OutBytes -l bandwidth', mk_hosts=>['10.2.5.8'],}
      
  
create a nagios command, and use it

    omd::nagios::command {check_nrpe_long: site=>'irfu', command => '/usr/lib/nagios/plugins/check_nrpe -u -H $HOSTADDRESS$ -c $ARG1$ -t $ARG2$'}
    omd::check_mk::legacy::service {'dummy_cvmfs': site=> 'irfu', command =>'check_nrpe_long!check_hung_ncm!300', mk_tags=>['wn']}

#### monitoring puppet (server side)
    omd::check_mk::server::plugins::puppet { 'irfu': }

#### puppetdb cleanup

If you have nodes that should not be monitored anymore using the puppetdb (removed nodes), you can remove them from the monitoring using this command :

    puppet node clean --unexport <nodename>
    puppet node deactivate <nodename>

#### foreman integration

If you happen to be using foreman for managing your nodes, take a look at the puppetdb_foreman plugin (for foreman), which is aslo shiped as an RPM (ruby193-rubygem-puppetdb_foreman) by the foreman team :
https://github.com/theforeman/puppetdb_foreman




## How to use the client side
------------------------------

Install the check_mk agent. This will start/enable the xinetd check_mk service :
    
    #using hiera for specifying the IP whitelist
    include omd::check_mk::agent
    
Add a check_mk tag "nagios" on a host. You can now specify the monitoring network that should be used when exporting the node ipaddress to check_mk, in order to avoid using the ::ipaddress fact in case multiple networks are configured on a host (you should probably use hiera for that...) .

    omd::check_mk::addtag{nagios:}
    or
    ensure_resource( 'omd::check_mk::addtag' ,'nagios',{})
    or
    omd::check_mk::addtag{multi_networks: monitoring_network=> '10.0.0.0', monitoring_netmask: '255.255.255.0' }
    
    or add in hierra :
    # omd::monitoring_network: 10.0.0.0  
    # omd::monitoring_netmask: 255.255.255.0
    
    
Add an MRPE test that will be automatically inventoried ( and exporting a check_mk tag) :
    
    omd::check_mk::mrpe::check{'hung_nrpe': command=>'/usr/lib/nagios/plugins/check_procs -w :5 -C nrpe'}

#### monitoring puppet (client side)

    include omd::check_mk::plugins::puppet

## Todo
- refactor/rework
- lower puppet inter-dependencies on client hosts
- well, check the doc is correct :)
- add support for notification definition/setup
- see if we can remove the binary "waitmax" from the module

## notes

This implements exported resources and collectors for check_mk tags as explained in this blog, but adapted to OMD :
http://blog.matsharpe.com/2013/01/puppet-checkmk.html

If you limit cron usage, please make sure to allow the OMD users, for instance, add :
    cron::allow {irfu: } -> omd::site {'irfu': }
    
Tested on : Scientific Linux 6.5

## Changes

2015-05-07 : 

added the monitoring network/netmasks for omd::check_mk::addtag, so that this can be used on multi-homed hosts.
Without this, there was a chance the hosts would export a definition using the wrong ipaddress.

2015-02-18 : 

the omd::check_mk::addhost resource did not allow for purging manually added hosts. Those definitions have 
been moved into the puppet/ subdirectory.

This *WILL* require that you manually cleanup your check_mk host definitions in etc/check_mk/conf.d as it will 
create duplicate host resources. But now the puppet directory beeing managed, hosts removed from the puppet config will really be automagically 
removed from check_mk.

The puppet subdirectory was owned by root : owner is now the omd user.

Use text version of the "mode" param in puppet file resources (puppet warning).