/**
 * Creates a ldap connection
 *
 * The Parameter names are th same as used in the WATO interface (V 1.2.8p2 Raw),
 * except they're all lowercase and with _ instead of space
 * this makes it easier to test the connection manually and just copy the parameters into the puppetconfig
 * The following variables are REQUIRED:
 * $server    - the AD-Server name
 * $user_dn   - The user base dn (e.g. 'OU=Users,DC=example,DC=com')
 * $group_dn  - The group base dn (e.g. 'OU=Groups,DC=example,DC=com')
 * $bind_dn   - The bind DN
 * $bin_pw    - the bind Password
 *
 * $active_plugins:
 * _______________
 * This includes all check boxes in the "LDAP Attribute Sync Plugins" section of the wato.
 * I REALLY RECOMMEND trying the settings in the wato and looking them up in the file:
 * /omd/sites/{$sitename}/etc/check_mk/multisite.d/wato/user_connetions.mk
 * You can copy everything between "'active_plugins' : {" and "}, ....." into the puppet definition
 *
 * This are some examples, you can have multiple plugins,
 * seperated with coma (like the three plugins in the default value)
 *
 * This would enable ONLY the alias plugin (first checkbox in the wato)
 * "'alias': { }"
 * This would use the principalname as alias
 * "'alias': {'attr' : 'userPrincipalName',}"
 * The same works for mail
 * "'email': {'attr' : 'mail', },"
 * Or for the authentication expiration
 * "'auth_expire': { }"
 * The following assigns two ldap groups to the admin roles and one to the user role
 * and it does also activate the 'nested' value
 * "'groups_to_roles': {'admin':
 *    [u'CN=monitoring-admins,OU=Groups,OU=Zurich,DC=company,DC=com',
 *    u'CN=monitoring-admin,OU=Groups,OU=Zurich,DC=Zurich,DC=company,DC=com',],
 *    'nested': True,
 *    'user': [u'CN=monitoring-users,OU=Groups,OU=Zurich,DC=company,DC=com',]}"
 */

define omd::site::ldap(
  $server,
  $bind_dn,
  $bind_pw,
  $group_dn,
  $user_dn,
  $default_user_roles = ['user'], # Array of default roles
  $default_user_cgroups = undef, # Array of deafult contact groups
  $site_path="/opt/omd/sites/${name}",
  $active_plugins="'alias': {}, 'auth_expire': {}, 'email': {}", # These three are automatically set
  $port="389",
  $type="ad",
  $version="3",
  $lifetime="300",
  $debug_log="False",
  $user_scope='sub', # 'sub' for the whole subtree, 'base' for only the base dn, 'one' for
  $user_filter=undef,
  $group_scope='sub', #^
  $group_filter=undef,
  $uid_umlauts='keep', #'replace' to replace special characters, 'keep' to keep them
){

  $mk_msconfdir = "${site_path}/etc/check_mk/multisite.d/"

  file { "${mk_msconfdir}/ldap.mk":
    ensure => file,
    mode => '660',
    owner => $name,
    content => template('omd/ldap.mk.erb'),
  }
}
