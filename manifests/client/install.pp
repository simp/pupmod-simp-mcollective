# private class
class mcollective::client::install {
  assert_private()

  if $::mcollective::manage_packages {
    package { $::mcollective::client_package:
      ensure => $::mcollective::version,
    }
  }
}
