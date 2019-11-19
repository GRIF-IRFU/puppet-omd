# Change log

## [v1.1.0]

## 2015 -> 10/2019 : 

### changed
- Compatible with puppet5.
- Changed the default check-mk edition and version.
- reworked legacy checks to be compatible with cmk 1.6 where the check-mk variable disappeared.
See : https://checkmk.com/cms_cmc_migration.html
- param "with_repos" now just tells the module it should install check-mk from a user-managed repo

### removed
- consol.labs repo is not configured by default
 

## [v1.0.1] - 2015-05-07 : 

added the monitoring network/netmasks for omd::check_mk::addtag, so that this can be used on multi-homed hosts.
Without this, there was a chance the hosts would export a definition using the wrong ipaddress.


## 2015-02-18 : 

the omd::check_mk::addhost resource did not allow for purging manually added hosts. Those definitions have 
been moved into the puppet/ subdirectory.

This *WILL* require that you manually cleanup your check_mk host definitions in etc/check_mk/conf.d as it will 
create duplicate host resources. But now the puppet directory beeing managed, hosts removed from the puppet config will really be automagically 
removed from check_mk.

The puppet subdirectory was owned by root : owner is now the omd user.

Use text version of the "mode" param in puppet file resources (puppet warning).
