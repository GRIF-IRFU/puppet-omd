# RVG
#
# benoetigt folgenden Service auf dem Tomcat: 
#

# --- /etc/tomcat-/server.xml
# ...
# <Service name="jolokia">
#       <Connector 
#           port="8081" 
#           protocol="HTTP/1.1"
#           connectionTimeout="2000" />

#       <Engine name="jolokia" defaultHost="localhost">
#           <Host 
#               name="localhost"  
#               appBase="/var/lib/tomcat7*/webapps/jolokia-war-1.2.2">

#               <Context docBase="/var/lib/tomcat7*/webapps/jolokia-war-1.2.2" path="" />
#           </Host>
#       </Engine>
# </Service>
# ...
# ---
#
# und das joloki-war von hier: http://www.jolokia.org/download.html
#

class omd::check_mk::plugins::tomcat(
  $omd_sites=['all'],
) {
  
  file { "/usr/lib/check_mk_agent/plugins/mk_jolokia":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/tomcat/mk_jolokia.agent",
  }
  omd::check_mk::addtag{ "Tomcat": omd_sites=>$omd_sites }
}

define omd::check_mk::plugins::tomcat::server(
  $site=$name,
 ) {

  file {
  "/opt/omd/sites/${site}/share/check_mk/checks/jolokia_info":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/tomcat/jolokia_info.server";

  "/opt/omd/sites/${site}/share/check_mk/checks/jolokia_metrics.server":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/tomcat/jolokia_metrics.server";
  
    "/opt/omd/sites/${site}/share/check_mk/pnp-templates/check_mk-jolokia_metrics.gc.php":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/tomcat/check_mk-jolokia_metrics.gc.php";

     "/opt/omd/sites/${site}/share/check_mk/pnp-templates/check_mk-jolokia_metrics.mem.php":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/tomcat/check_mk-jolokia_metrics.mem.php";

     "/opt/omd/sites/${site}/share/check_mk/pnp-templates/check_mk-jolokia_metrics.threads.php":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/tomcat/check_mk-check_mk-jolokia_metrics.threads.php";

    "/opt/omd/sites/${site}/share/check_mk/pnp-templates/check_mk-jolokia_metrics.tp.php":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/tomcat/check_mk-check_mk-jolokia_metrics.tp.php";

    "/opt/omd/sites/${site}/share/check_mk/pnp-templates/check_mk-jolokia_metrics.uptime.php":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/tomcat/check_mk-check_mk-jolokia_metrics.uptime.php",
  }
}
