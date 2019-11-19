/**
 * This user define uses concat to add additional checks to the MRPE configuration.
 *
 * The resource name is the check name
 * arguments
 * - the command to run
 * - eventually, check_mk 'site names' so that the inventory only notifies this site
 * - eventually : a cache time (new since cmk 1.2.7) for the command
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

   #stip blanck chars from name
   $check_name=regsubst($name, ' ', '_', 'G')

   concat::fragment{"mrpe ${check_name}":
      target => "mrpe.cfg",
      content => "${check_name} ${command}\n",
      order => "${concat_order}",
   }

   #add a check_mk tag
   omd::check_mk::addtag{"${check_name}": omd_sites=>$omd_sites}
 }
