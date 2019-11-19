/*
 * This is a class that you can use to create an apache VHOST, that will
 * - listen on a defined port
 * - activate and force SSL for every OMD site provided
 * - allow access to a secure and authenticate (restrict using certificates ) an HTTPS version of the unsecure http version, by using user certificates as the user names thanks to fakebasicauth
 *
 * AND :
 * - for each 'site' given as mandatory argument, creates a < Location /> requiring the users created in the multisite htpasswd file
 */

 class omd::ssl::vhost (
  $port=443,
  $sites, #this is a list of sites
  $ssl_cert='/etc/grid-security/hostcert.pem',
  $ssl_key='/etc/grid-security/hostkey.pem',
  $ca_dir='/etc/grid-security/certificates',
  $sslciphersuite='ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS',
  $ssl_force_client_cert=true, #this is the "SSLVerifyClient require" option. If false, this will be defined as SSLVerifyClient optional
  $admin_mail='admin mail not set',
  $priority='zzzz',
  String $logdir,
 )
 {
  include ::apache::mod::ssl
  #
  # OMD apache setup. puppetlabs apache removes /etc/httpd/conf.d/zzz_omd.conf
  #
  file {'/etc/httpd/conf.d/zzz_omd.conf':
    ensure=>link,
    target => '/omd/versions/default/share/omd/apache.conf'
  } ~> Service['httpd']

  ::apache::custom_config { 'omd_ssl':
    ensure   => present,
    content  => template('omd/ssl/vhost.erb'),
    priority => $priority,
  }

  #omd raw 1.2.8+ : disable cookie authentication if using SSL
  $sites.each | $site | {

    omd::config { "omd no cookie auth for ${site}": site => $site,  action => 'set', var => 'MULTISITE_COOKIE_AUTH', value => 'off' }

  }

}
