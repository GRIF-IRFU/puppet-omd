/**
 * A small class to make sure we manage (or not) the check_mk localcheck directory.
 * Would be a pitty if we decided to change a check timing and then duplicate it if not doing the cleanup behind the scenes.
 * 
 */
 class omd::check_mk::localcheck::directory(
   $path = '/usr/lib/check_mk_agent/local/',
   $purge = true,
 )
 {
   file { "${path}":
     ensure=>directory,
     owner => 0,
     group => 0,
     mode  => '0755',
     recurse => true,
     purge => $purge ? { true => true , default => false},
     force => true,
   }
 }
