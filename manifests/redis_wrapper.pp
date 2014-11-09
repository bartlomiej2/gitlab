# == Class: gitlab::redis_wrapper
#
# This class exists to
# 1. Install redis package (by fsalum-redis module)
# 2. Configure redis instance (required for GitLab)
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class is not intended to be used directly.
#
#
# === Links
#
# * {Puppet module for Redis Server}[https://forge.puppetlabs.com/fsalum/redis]
#
#
# === Authors
#
# * Evgeniy Evtushenko <mailto:evgeniye@crytek.com>
#
class gitlab::redis_wrapper {
  # Install Redis instance for GitLab
  class { 'redis':
    conf_bind => $redis_address,
    conf_port => $redis_port,
  }
}
