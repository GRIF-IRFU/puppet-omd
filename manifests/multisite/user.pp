/**
 * User defined type that will allow defining a user in multisite
 *
 * The concat initialisation is done during the omd site setup, we just realize the virtual resources.
 */
define omd::multisite::user(
  String  $site, #this is the site for which the user will be created
  Enum['guest', 'admin', 'user'] $privileges = 'guest', #can be guest, admin or user.
  String  $username=$name, #needed in case of multiple omd sites, to override duplicate definitions
  Boolean $convert_to_legacyDN=false,  #is the username given as an apache legacy User Dn, or compatible with RFC 2253 - couldn't get RFC2253 to work with fakebasickauth. In case of new DNs, these are "refersed"
  ) {
  realize(Omd::Multisite::Userinit[$site])

  $concat_number = $privileges ? {
    guest => '30',
    admin => '60',
    user  => '90',
    default => '30'
  }

  if($convert_to_legacyDN) {
    $final_uname=inline_template('<%="/"+@username.split(",").reverse.join("/") -%>')
  } else {
    $final_uname=$username
  }

  concat::fragment{"multisite_${site}_${name}":
    target => "multisite_${site}_users",
    content => "  '${final_uname}',",
    order => $concat_number,
  }
}
