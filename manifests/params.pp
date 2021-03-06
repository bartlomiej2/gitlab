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
  $ensure	    = 'present'
  $status	    = 'enabled'
  $gitlab_user	    = 'git'
  $gitlab_group     = $gitlab_user
  $gitlab_home      = "/home/${gitlab_user}"
  $gitlab_version   = '7-4-stable'
  $gitlab_address   = "gitlab.${::fqdn}"
  $redis_address    = '127.0.0.1'
  $redis_port       = '6379'
  $unicorn_address  = '127.0.0.1'
  $unicorn_port	    = '8880'
  $ensure_https	    = true
  $http_user	    = 'apache'
  $http_group	    = 'apache'


  # packages
  case $::operatingsystem { # see http://j.mp/x6Mtba for a list of known values
    'CentOS', 'Fedora', 'Scientific': {
      $package = [ 'libicu-devel', 'cmake', 'postgresql-devel' ]
    }
    'Debian', 'Ubuntu': {
      $package = [ 'FIXME/TODO' ]
    }
    default: {
      fail("\"${module_name}\" provides no package default value for \"${::operatingsystem}\"")
    }
  }
  $git_package = 'git'

  # service parameters
  case $::operatingsystem {
    'CentOS', 'Fedora', 'Scientific', 'Debian', 'Ubuntu': {
      $service_name       = 'gitlab'
      $service_hasrestart = true
      $service_hasstatus  = true
    }
    default: {
      fail("\"${module_name}\" provides no service parameters for \"${::operatingsystem}\"")
    }
  }


  #### Internal module values

  # GitLab source repository
  $gitlab_source_url = 'https://gitlab.com/gitlab-org/gitlab-ce.git'

  # GitLab configuration files
  $gitlab_config_files = [ 'gitlab.yml', 'unicorn.rb', 'resque.yml', 'database.yml' ]
  $gitlab_shell_config_files = [ 'config.yml' ]
  $gitlab_dirs = [ 'gitlab-sattelites', 'gitlab-shell', 'repositories' ]

}
