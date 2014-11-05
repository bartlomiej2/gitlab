# == Class: gitlab::params
#
# This class exists to
# 1. Declutter the default value assignment for class parameters.
# 2. Manage internally used module variables in a central place.
#
# Therefore, many operating system dependent differences (names, paths, ...)
# are addressed in here.
#
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
class gitlab::params {

  #### Default values for the parameters of the main module class, init.pp

  # ensure
  $ensure = 'present'

  # autoupgrade
  $autoupgrade = false

  # autoload_class
  $autoload_class = false

  $gitlab_user    = 'git'
  $gitlab_home    = "/home/${gitlab_user}"
  $redis_address  = '127.0.0.1'
  $redis_port     = '6379'

  # packages
  case $::operatingsystem { # see http://j.mp/x6Mtba for a list of known values
    'CentOS', 'Fedora', 'Scientific': {
      $package = [ 'git', 'libicu-devel', 'cmake', 'postgresql-devel' ]
    }
    'Debian', 'Ubuntu': {
      $package = [ 'FIXME/TODO' ]
    }
    default: {
      fail("\"${module_name}\" provides no package default value for \"${::operatingsystem}\"")
    }
  }

  # debug
  $debug = false



  #### Internal module values

  # Ruby version which will be installed for GitLab user by RVM
  $ruby_version = '2.1.2'

}
