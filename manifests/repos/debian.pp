class omd::repos::debian {  

include '::apt'

 apt::repository { 'omd':
    url => 'http://labs.consol.de/repo/stable/debian',
    distro => "$::lsbdistcodename",
    repository => 'main',
    key => 'F8C1CA08A57B9ED7',
    keyserver => 'keys.gnupg.net',
    before => Package['omd'],
    #include_src       => false
  }

}
