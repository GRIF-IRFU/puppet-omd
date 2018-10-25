/**
 * User defined type that will allow defining a user in multisite
 * 
 * The concat initialisation is done during the omd site setup, we just realize the virtual resources.
 */
define omd::multisite::user(
  $site, #this is the site for which the user will be created
  $privileges=guest, #can be guest, admin or user. Anything else will be guest.
  $username=$name, #needed in case of multiple omd sites, to override duplicate definitions
  ) {
  realize(Omd::Multisite::Userinit[$site])
  
  $concat_number = $privileges ? {
    guest => '30',
    admin => '60',
    user  => '90',
    default => '30'
  }

  #the following include is absolutely required to prevent concat from choking on tmpfile creation - because of the virtual concat base
#  include concat::setup
  concat::fragment{"multisite_${site}_${name}":
    target => "multisite_${site}_users",
    content => "  '${username}',",
    order => $concat_number,
  }
}
