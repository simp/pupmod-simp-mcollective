# private class
class mcollective::server::service {
  assert_private()

  service { $::mcollective::service_name:
    ensure => 'running',
    enable => true,
  }
}
