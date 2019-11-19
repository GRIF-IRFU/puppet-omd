# the inventory function
#split every agent output line and make those inventoried elements
def inventory_simpleinv(info):
    for line in info:
        invitem=line[0] #1st row = item to get inventoried
        val=line[1:] #the rest of the line is a list of things that should always be there
        val.sort()
        yield invitem, val
        
# the check function
def check_simpleinv(item, params, info):
    for line in info:
        line_item=line[0]
        line_params=line[1:]
        if line_item == item :
            
             # compute the exact difference.
            exceeding = []
            for o in line_params:
                if o not in params :
                    exceeding.append(o)

            missing = []
            for o in params:
                if o not in line_params:
                    missing.append(o)
            
            if not missing and not exceeding:
                return (0, "%s exactly as expected" % item)

            infos = []
            if missing:
                infos.append("missing: %s" % ",".join(missing))
            if exceeding:
                infos.append("exceeding: %s" % ",".join(exceeding))
            infotext = ", ".join(infos)
            return (1, infotext)

    #if we're here : the item was not found
    return 3, "Error : %s was not found in inventory !" % item

# declare the check to Check_MK
check_info["simpleinv"] = {
    'check_function':            check_simpleinv,
    'inventory_function':        inventory_simpleinv,
    'service_description':       '%s inventory',
    'has_perfdata':              False,
}
