class omd::check_mk::plugins::kav(
  $omd_sites=['all'],
) {
  
  file { "/usr/lib/check_mk_agent/plugins/kaspersky_av":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/kav/kaspersky_av.agent",
  }
  omd::check_mk::addtag{ "kav": omd_sites=>$omd_sites }
}

define omd::check_mk::plugins::kav::server(
  $site=$name,
 ) {

  file {
  "/opt/omd/sites/${site}/share/check_mk/checks/kaspersky_av_tasks":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/kav/kaspersky_av_tasks.server";

  "/opt/omd/sites/${site}/share/check_mk/checks/kaspersky_av_quarantine":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/kav/kaspersky_av_quarantine.server";
  
   "/opt/omd/sites/${site}/share/check_mk/checks/kaspersky_av_updates":
    owner   => root,
    group   => root,
    ensure  => file,
    mode    => 0655,
    source  => "puppet:///modules/omd/plugins/kav/kaspersky_av_updates.server";
  }
}
