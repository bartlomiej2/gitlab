# == Class: gitlab::database
#
# This class exists to
# 1. Create database for GitLab by using puppetlabs-postgresql module
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
# * {Puppet Docs: Using Parameterized Classes}[http://j.mp/nVpyWY]
#
#
# === Authors
#
# * Evgeniy Evtushenko <mailto:evgeniye@crytek.com>
#
class gitlab::database {
  # PostgreSQL server version >=9.1 should be installed at this moment.
  # Create database for GitLab and set grant privileges to 'git' user
  postgresql::server::db { 'gitlabhq_production':
    user      => $gitlab::gitlab_user,
    password  => postgresql_password($gitlab::gitlab_user, 'mypassword'),
  }
}
