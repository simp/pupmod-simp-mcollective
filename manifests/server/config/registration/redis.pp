#
class mcollective::server::config::registration::redis {
  assert_private()

  ::mcollective::server::setting { 'registerinterval':
    value => 10,
  }

  ::mcollective::server::setting { 'registration':
    value => 'redis',
  }

  ::mcollective::plugin { 'registration/redis': }
}
