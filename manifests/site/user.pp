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
   $convert_to_legacyDN=false,  #is the username given as an apache legacy User Dn, or compatible with RFC 2253 - couldn't get RFC2253 to work with fakebasickauth. In case of new DNs, these are "refersed"
 ) {

  #if the ensure is absent, then erase the user from the file.
  #if present , create it
  #if something else, warn
  #strip anything after the comment char "%".
  $username=regsubst($name,'%.*','')

  #if we need to convert new RFC 2253 DNs to legacy DNs (i.e : we use fakebasickauth with DNs), do it now (and don't re-convert the multisite username afterwards)
  if($convert_to_legacyDN) {
   $final_uname=inline_template('<%="/"+@username.split(",").reverse.join("/") -%>')
  } else {
    $final_uname=$username
  }

   $user_line= $ensure ? {
     'present' =>"${final_uname}:${pass_md5}",
     'absent' =>"${final_uname}:!disabled",
     default => "none",
   }
   if($user_line!= "none") {
     file_line { "omd $site user ${name}":
       match => "^${final_uname}:",
       line => $user_line,
       path => "/opt/omd/sites/${site}/etc/htpasswd",
       require => Omd::Site["$site"]
     }
     #create the multisite authorizations too
     omd::multisite::user{"${name}": site=>$site, privileges=>$privileges, username=>"${username}", convert_to_legacyDN => $convert_to_legacyDN }
   } else {
     notify {"warning : cannot interpret the ensure '${ensure}' for omd::site::user::${username}": loglevel => warning}
   }

 }
