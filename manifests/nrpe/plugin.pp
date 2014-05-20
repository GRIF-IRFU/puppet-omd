/**
 * This ensures the NRPE plugin package is installed.
 * 
 */
 
 class omd::nrpe::plugin($ensure='present') {
   package {nrpe-plugin: ensure=>$ensure}
 }
