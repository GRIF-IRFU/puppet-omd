/**
 * This will add a nagios command.cfg file named like the nagios command, in the OMD site etc/nagios/conf.d directory
 * The name of the resource is the name of the command
 */
define omd::nagios::command(
  $site,
  $command
) {
  file { "/opt/omd/sites/${site}/etc/nagios/conf.d/command_${name}.cfg":
    owner => $site,
    group=> $site,
    content => "define command {
      command_name ${name}
      command_line ${command}
      }\n",
    require => Exec["omd create site ${site}"]
  }
  ->
  Exec <| tag=="check_mk_refresh_site" |>
}
