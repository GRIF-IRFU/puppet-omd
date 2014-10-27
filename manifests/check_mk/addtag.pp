#
# Main client side defined type. All we do here is establish a dependancy chain from an instance
# of the 'addtag' type.
#
# Note : only digits and metters are allowed, therefore a regsubst is done and all unknown chars will become "_".
#
define omd::check_mk::addtag(
  $omd_sites=['all'], #this allows to export the resources for all omd sites, or selected ones.
) {
  #define our hostnames and inventory exported resources for each OMD site
  #It is the up to the collecting servers to not duplicate resources by collecting both their dedicated resources and the global ones (the "all" tag)
  
  $tagname=regsubst($name,'[^a-zA-Z0-9_]','_','G')
  #$tagname="$name"
  
  #add the tag to the catalog :
  omd::check_mk::tag {$tagname:}
  
  #to allow duplicate resources, add a #${name} to each omd_sites, i.e add the tag name
  $tag_sites=regsubst($omd_sites,'$',"#${tagname}")
  omd::check_mk::build_exported_resources {$tag_sites : allow_duplicates => '#'}
  
  #to prevent dependency cycles, we use the "dummy" sub-define "tag" for ordering. We must tag everything before declaring the exported resources
  Omd::Check_mk::Tag["$tagname"] -> Omd::Check_mk::Build_exported_resources <| |>
  
}
 
