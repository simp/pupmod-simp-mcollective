# private class
class mcollective::common::config::connector::rabbitmq {
  assert_private()

  ::mcollective::common::setting { 'direct_addressing':
    value => 1,
  }

  ::mcollective::common::setting { 'plugin.rabbitmq.vhost':
    value => $::mcollective::rabbitmq_vhost,
  }

  ::mcollective::common::setting { 'plugin.rabbitmq.randomize':
    value => true,
  }

  $pool_size = size(flatten([$::mcollective::middleware_hosts]))
  ::mcollective::common::setting { 'plugin.rabbitmq.pool.size':
    value => $pool_size,
  }

  $indexes = mco_array_to_string(range('1', $pool_size))
  ::mcollective::common::config::connector::rabbitmq::hosts_iteration { $indexes: }

  ::mcollective::common::setting { 'plugin.rabbitmq.heartbeat_interval':
    value => $::mcollective::middleware_heartbeat_interval,
  }

}
