class omd::repos::debian {  

include '::apt'

 apt::source { 'omd':
    location => 'http://labs.consol.de/repo/stable/debian',
    release => "$::lsbdistcodename",
    repos => 'main',
    key => 'F8C1CA08A57B9ED7',
    key_server => 'keys.gnupg.net',
    before => Package['omd'],
    include_src       => false
  }

}
