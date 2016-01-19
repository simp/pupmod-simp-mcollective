# private class
class mcollective::server::config {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  datacat { 'mcollective::server':
    owner    => 'root',
    group    => '0',
    mode     => '0400',
    path     => $mcollective::server_config_file_real,
    template => 'mcollective/settings.cfg.erb',
  }

  mcollective::server::setting { 'classesfile':
    value => $mcollective::classesfile,
  }

  mcollective::server::setting { 'daemonize':
    value => bool2num($::mcollective::server_daemonize),
  }

  mcollective::server::setting { 'logfile':
    value => $mcollective::server_logfile,
  }

  mcollective::server::setting { 'loglevel':
    value => $mcollective::server_loglevel,
  }

  file { "${mcollective::confdir}/policies":
    ensure => 'directory',
    owner  => 'root',
    group  => '0',
    mode   => '0700',
  }

  file { $mcollective::ssldir:
    ensure => 'directory',
    owner  => 'root',
    group  => '0',
    mode   => '0755',
  }

  if $::mcollective::middleware_ssl or $mcollective::securityprovider == 'ssl' {

    file { $::mcollective::middleware_ssl_ca_path:
      owner  => 'root',
      group  => '0',
      mode   => '0444',
      source => $::mcollective::middleware_ssl_ca_real,
    }

    file { $::mcollective::middleware_ssl_key_path:
      owner  => 'root',
      group  => '0',
      mode   => '0400',
      source => $::mcollective::middleware_ssl_key_real,
    }

    file { $::mcollective::middleware_ssl_cert_path:
      owner  => 'root',
      group  => '0',
      mode   => '0444',
      source => $::mcollective::middleware_ssl_cert_real,
    }

    if $mcollective::ssl_mco_autokeys {

      file { "${mcollective::confdir}/ssl/mco_autokeys":
        ensure => directory,
        mode   => '0750',
        owner  => 'root',
        group  => 'puppet'
      }
      file { 'mco_priv_key':
        path    => "${mcollective::confdir}/ssl/mco_autokeys/mco_private.pem",
        content => mco_autokey('2048', true),
        mode    => '0400',
        owner   => 'root',
        group   => 'puppet',
        require => File['/etc/mcollective/ssl/mco_autokeys']
      }
      file { 'mco_pub_key':
        path    => "${mcollective::confdir}/ssl/mco_autokeys/mco_public.pem",
        content => mco_autokey('2048'),
        mode    => '0400',
        owner   => 'root',
        group   => 'puppet',
        require => File['mco_priv_key'],
      }
    }
    else {
      file { "${mcollective::confdir}/ssl/server_public.pem":
        owner  => 'root',
        group  => '0',
        mode   => '0444',
        source => $mcollective::ssl_mco_public,
      }

      file { "${mcollective::confdir}/ssl/server_private.pem":
        owner  => 'root',
        group  => '0',
        mode   => '0400',
        source => $mcollective::ssl_mco_private
      }
    }
  }

  mcollective::soft_include { [
    "::mcollective::server::config::connector::${mcollective::connector}",
    "::mcollective::server::config::securityprovider::${mcollective::securityprovider}",
    "::mcollective::server::config::factsource::${mcollective::factsource}",
    "::mcollective::server::config::registration::${mcollective::registration}",
    "::mcollective::server::config::rpcauditprovider::${mcollective::rpcauditprovider}",
    "::mcollective::server::config::rpcauthprovider::${mcollective::rpcauthprovider}",
  ]:
    start => Anchor['mcollective::server::config::begin'],
    end   => Anchor['mcollective::server::config::end'],
  }

  anchor { 'mcollective::server::config::begin': }
  anchor { 'mcollective::server::config::end': }
}
