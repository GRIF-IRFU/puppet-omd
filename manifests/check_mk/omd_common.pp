class omd::check_mk::omd_common {
  
  #this is now a "DUMMY" exec, that will notify all other execs with the tag "check_mk_refresh_site".
  #each OMD site will be created with this tag, and this will allow us to only schedule one refresh per site, no matter what we do.
  exec { "checkmk_refresh_all":
    #command     => "bash -c 'cd /opt/omd/sites ; for i in * ; do sudo -i -u \${i} \${i}/bin/cmk -O ; done'",
    command     => "/bin/true",
    refreshonly => true,
  }
  ~>
  Exec <| tag=="check_mk_refresh_site" |>
}
