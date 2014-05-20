/**
 * User define that allows to either add or remove users for an omd site htaccess.
 * The resource name is the user name
 * 
 * Anything after a "%" will be tripped off, this will enable the same user to be defined on different omd sites
 */
 define omd::site::user(
   $site, #required : this is the omd site to change
   $ensure=present,
   $pass_md5='HSR49nEt7LVSo', #if present, must be an MD5 hash such as what "openssl password toto" gives. Default : 'changeme'
   $privileges=guest, #can be guest/admin/user. This is passed to the multisite config
 ) {
   
   #if the ensure is absent, then erase the user from the file.
   #if present , create it
   #if something else, warn
   
   #strip anything after the comment char "%".
   $username=regsubst($name,'%.*','')
   
   $user_line= $ensure ? {
     present =>"${username}:${pass_md5}",
     absent =>"${username}:!disabled",
     default => "none",
   }
   if($user_line!= "none") {
     file_line { "omd user ${name}":
       match => "^${username}:",
       line => $user_line,
       path => "/opt/omd/sites/${site}/etc/htpasswd",
       require => Omd::Site["$site"]
     }
     #create the multisite authorizations too
     omd::multisite::user{"${name}": site=>$site, privileges=>$privileges, username=>"${username}"}
   } else {
     notify {"warning : cannot interpret the ensure '${ensure}' for oms::site::user::${username}": loglevel => warning}
   }
   
 }
