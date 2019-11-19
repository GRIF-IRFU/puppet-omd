/**
 * run an omd config command for a specific site
 */
 define omd::config(
   $site,
   $action = 'set',
   $var ,
   $value ,
)
 {

   #we cannot :
   # - execute a config (unles...), require the site to stop and its restart afterwards because we have no provider : we need to have an exec stub for now
   exec { "omd STUB for config $var on ${site}":
      command => "true",
      path => ['/usr/bin','/usr/sbin','/bin','/sbin',],
      require => Exec["omd create site ${site}"],
      notify => Exec["omd maintenance stop site ${site}","omd config for ${site} var $var", "omd maintenance start site ${site}"],
      unless => "omd config ${site} show $var | egrep -q '(${var}: )?${value}'", #returns 0 if already set, hence disables this exec
    }

   exec { "omd config for ${site} var $var":
      command => "omd config ${site} $action $var $value > /dev/null 2>&1",
      path => ['/usr/bin','/usr/sbin','/bin','/sbin',],
      refreshonly => true ,
      require => Exec["omd maintenance stop site ${site}"],
      before => Exec["omd maintenance start site ${site}"],
    }

 }
