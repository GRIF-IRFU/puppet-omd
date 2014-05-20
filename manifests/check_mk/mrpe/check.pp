/**
 * This user define uses concat to add additional checks to the MRPE configuration.
 * 
 * The resource name is the check name
 * arguments
 * - the command to run
 * - eventually, check_mk 'site names' so that the inventory only notifies this site
 * 
 * The defined resouce will automaticall add a check_mk tag, thus triggering an inventory if using exported resources.
 */
 
 define omd::check_mk::mrpe::check(
   $command,
   $concat_order=20, #you should not need this, but you can always override the file ordering with this
   $omd_sites=['all'], #this can be an array
 ){
   #make sure the concat base is there
   include omd::check_mk::mrpe
   
   concat::fragment{"mrpe ${name}":
      target => "mrpe.cfg",
      content => "${name} ${command}\n",
      order => "${concat_order}",
   }
   
   #add a check_mk tag
   omd::check_mk::addtag{"${name}": omd_sites=>$omd_sites}
 }
