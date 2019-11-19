#!/bin/sh
#
# output format MUST be : 
# thing_to_be_inventoried things to inventory (will be sorted).
#
# examples :
# cpuA speed 2.4 THz (will be sorted after cpuA... so bad idea)
# cpuB 2.4_Thz 37cores

echo '<<<simpleinv>>>'

#memory inventory :
#example output :
#DIMM_A1 4096_MB 1333_MHz
#DIMM_A2 4096_MB 1333_MHz
#...
# tested on el6, el7 and debian
dmidecode -t 17 | egrep "^[[:blank:]]+(Locator|Size|Speed|Bank Locator)"|sed -e 's/^[[:blank:]]*//;s/: /:/;s/ *$//;s/ /_/g'|xargs -L4 echo|gawk  '{delete line ; for(i=1; i<=NF;i++){split($i,out,":"); if(out[2] ~ "Not_Specified"){out[2]=""}  ; line[out[1]]=out[2] } ; if(line["Locator"]!="" && line["Bank_Locator"]!=""){line["Bank_Locator"]="_"line["Bank_Locator"]} ; printf "%s%s %s %s\n",line["Locator"],line["Bank_Locator"],line["Size"],line["Speed"] ; }' |grep -iv No_Module_Installed

#cpus inventory
grep "model name" /proc/cpuinfo |sed -e 's/.*: //;s/  */_/g'|sort|uniq -c|gawk '{print "processors " $1 "x" $2}'
