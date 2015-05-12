#
# Main client side defined type. All we do here is establish a dependancy chain from an instance
# of the 'addtag' type.
# 
# Note : only digits and metters are allowed for tags (resource name), therefore a regsubst is done and all unknown chars will become "_".
#
# Arguments :
# [ omd_sites ]
#
# The list of sites on which the tag will be exported.
#
# [ monitoring_network ]
# [ monitoring_netmask ]
#
# The network address that must be used when exporting a node definition to OMD.
# This is usefull in case you have multiple networks defined on a node, in which case the ipaddress fact contains the first interface IP, not necessarily what you want.
# and not specifying the IP but the network allows to remain generic.
# 
# For instance :
#  - br0 has ip 10.0.0.1/24
#  - enp12s0 has ip 123.456.789.1/24
# In case you want your OMD host to reach the node via enp12s0, you can't use ::ipaddress which might (will?) contain 10.0.0.1.
#
# In that case, define (in hiera or you call to addtag) :
# 
# omd::monitoring_network: 10.0.0.0  
# omd::monitoring_netmask: 255.255.255.0
#
# 
#
define omd::check_mk::addtag(
  $omd_sites=['all'], #this allows to export the resources for all omd sites, or selected ones.
  $monitoring_network=hiera('omd::monitoring_network',undef),
  $monitoring_netmask=hiera('omd::monitoring_netmask',undef)
) {
  #define our hostnames and inventory exported resources for each OMD site
  #It is the up to the collecting servers to not duplicate resources by collecting both their dedicated resources and the global ones (the "all" tag)
  
  $tagname=regsubst($name,'[^a-zA-Z0-9._]','_','G')
  
  #add the tag to the catalog :
  omd::check_mk::tag {$tagname:}
  
  #to allow duplicate resources, add a #${name} to each omd_sites, i.e add the tag name
  $tag_sites=regsubst($omd_sites,'$',"#${tagname}")
  omd::check_mk::build_exported_resources {$tag_sites : allow_duplicates => '#', monitoring_network=>$monitoring_network , monitoring_netmask => $monitoring_netmask}
  
  #to prevent dependency cycles, we use the "dummy" sub-define "tag" for ordering. We must tag everything before declaring the exported resources
  Omd::Check_mk::Tag["$tagname"] -> Omd::Check_mk::Build_exported_resources <| |>
  
}
 
