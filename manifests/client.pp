# private class
# Installs the client and sets up /etc/mcollective/client.cfg (global/common
# configuration)
class mcollective::client {
  assert_private()

  contain ::mcollective::client::install
  contain ::mcollective::client::config

  Class['mcollective::client::install'] ->
  Class['mcollective::client::config']
}
