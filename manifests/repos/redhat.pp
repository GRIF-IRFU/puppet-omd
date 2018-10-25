class omd::repos::redhat {
  #stable releases
  yumrepo { "omd":
    baseurl => "https://labs.consol.de/repo/stable/rhel${::operatingsystemmajrelease}/${::architecture}",
    descr => "Consol* Labs Repository",
    enabled => 1,
    gpgcheck => 1,
    gpgkey => 'http://labs.consol.de/repo/stable/RPM-GPG-KEY',
  }
  
  #test releases
#  yumrepo { "omd-testing":
#    baseurl => "https://labs.consol.de/repo/testing/rhel${::operatingsystemmajrelease}/${::architecture}",
#    descr => "Consol* Labs TESTING Repository",
#    enabled => 1,
#    gpgcheck => 1,
#    gpgkey => 'https://labs.consol.de/repo/testing/RPM-GPG-KEY',
#  }  
}
