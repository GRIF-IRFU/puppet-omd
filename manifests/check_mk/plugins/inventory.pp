class omd::check_mk::plugins::inventory(
  $omd_sites=['all'],
  $inv_checkfile='mk_inventory',
  $inv_version='.1.2.8p21.cre',
) {

  ::omd::check_mk::plugins::agent { $inv_checkfile : sourcefile => "${inv_checkfile}${inv_version}" }

  omd::check_mk::addtag{"inventory": omd_sites=>$omd_sites }
}
