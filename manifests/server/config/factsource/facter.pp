# private class
class mcollective::server::config::factsource::facter {
  assert_private()

  ::mcollective::plugin { 'facter':
    type       => 'facts',
    package    => true,
    has_client => false,
  }

  ::mcollective::server::setting { 'factsource':
    value => 'facter',
  }

  ::mcollective::server::setting { 'fact_cache_time':
    value => 300,
  }
}
