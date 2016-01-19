# private class
class mcollective::server::config::securityprovider::ssl {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { $mcollective::ssl_client_certs_dir_real:
    ensure  => 'directory',
    owner   => 'root',
    group   => '0',
    purge   => true,
    recurse => true,
    mode    => '0400',
    source  => $mcollective::ssl_client_certs,
  }

  mcollective::server::setting { 'plugin.ssl_client_cert_dir':
    value => $mcollective::ssl_client_certs_dir_real,
  }

  if $mcollective::ssl_mco_autokeys {
    mcollective::server::setting { 'plugin.ssl_server_public':
      value => "${mcollective::confdir}/ssl/mco_autokeys/mco_public.pem",
    }

    mcollective::server::setting { 'plugin.ssl_server_private':
      value => "${mcollective::confdir}/ssl/mco_autokeys/mco_private.pem",
    }
  }
  else {
    mcollective::server::setting { 'plugin.ssl_server_public':
      value => "${mcollective::confdir}/ssl/server_public.pem",
    }

    mcollective::server::setting { 'plugin.ssl_server_private':
      value => "${mcollective::confdir}/ssl/server_private.pem",
    }
  }
}
