# private define
define mcollective::user::connector(
  $username,
  $callerid,
  $homedir,
  $order,
  $connector,
  $middleware_ssl,
) {
  $i = regsubst($title, "^${username}_", '')

  if !defined('::mcollective') {
    fail('You must include `::mcollective` before calling `mcollective::common::config::connector::activemq::hosts_iteration`')
  }


  if $middleware_ssl {
    ::mcollective::user::setting { "${username} plugin.${connector}.pool.${i}.ssl.ca":
      setting  => "plugin.${connector}.pool.${i}.ssl.ca",
      username => $username,
      order    => $order,
      value    => "${homedir}/.mcollective.d/credentials/certs/ca.pem",
    }

    ::mcollective::user::setting { "${username} plugin.${connector}.pool.${i}.ssl.cert":
      setting  => "plugin.${connector}.pool.${i}.ssl.cert",
      username => $username,
      order    => $order,
      value    => "${homedir}/.mcollective.d/credentials/certs/${callerid}.pem",
    }

    ::mcollective::user::setting { "${username} plugin.${connector}.pool.${i}.ssl.key":
      setting  => "plugin.${connector}.pool.${i}.ssl.key",
      username => $username,
      order    => $order,
      value    => "${homedir}/.mcollective.d/credentials/private_keys/${callerid}.pem",
    }
  }
}
