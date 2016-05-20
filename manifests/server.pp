# private class
class mcollective::server {
  assert_private()

  contain ::mcollective::server::install
  contain ::mcollective::server::config
  contain ::mcollective::server::service

  Class['mcollective::server::install'] ->
  Class['mcollective::server::config']  ~>
  Class['mcollective::server::service']
}
