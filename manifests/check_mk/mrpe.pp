/**
 * This ensures themain mrpe.cfg file exists.
 * This will be included by subsequent check_mk::mrpe::check calls
 * 
 */
 
 class omd::check_mk::mrpe($mk_location='/etc/check_mk') {
   $mrpe_cfg="${mk_location}/mrpe.cfg"
  
   include omd::check_mk::agent
   
   concat{"mrpe.cfg":
      owner => root,
      group => root,
      mode => '644',
      path => $mrpe_cfg,
      require => File[$mk_location]
   }
 }
