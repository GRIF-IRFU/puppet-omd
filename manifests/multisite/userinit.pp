/**
 * This is a define that is meant to setup the base concat for every omd::multisite::user that are added.
 * 
 * This one will be first instanciated as virtual and only realized if there is a user-defined multisite user
 * The resource name is the OMD sitename
 * 
 * concat numbers for the roles : 
 * guest 30
 * admin60
 * User 90
 */

define omd::multisite::userinit() {
   
   concat{"multisite_${name}_users":
      owner => root,
      group => root,
      mode => '755',
      path => "/opt/omd/sites/${name}/etc/check_mk/multisite.d/users.mk",
      require => Exec["omd create site ${name}"]
   }
   concat::fragment{"multisite_${name}_guest_header":
      target => "multisite_${name}_users",
      content => "guest_users = [\n",
      order => "29",
   }
   concat::fragment{"multisite_${name}_guest_footer":
      target => "multisite_${name}_users",
      content => "]\n",
      order => "31",
   }
   concat::fragment{"multisite_${name}_admin_header":
      target => "multisite_${name}_users",
      content => "admin_users = [\n",
      order => "59",
   }
   concat::fragment{"multisite_${name}_admin_footer":
      target => "multisite_${name}_users",
      content => "]\n",
      order => "61",
   }
   concat::fragment{"multisite_${name}_user_header":
      target => "multisite_${name}_users",
      content => "users = [\n",
      order => "89",
   }
   concat::fragment{"multisite_${name}_user_footer":
      target => "multisite_${name}_users",
      content => "]\n",
      order => "91",
   }
   
 }
