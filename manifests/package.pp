# == Class: gitlab::package
#
# This class exists to coordinate all software package management related
# actions, functionality and logical units in a central place.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'gitlab::package': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Evgeniy Evtushenko <mailto:evgeniye@crytek.com>
#
class gitlab::package {

  #### Package management

  # set params: in operation
  if $gitlab::ensure == 'present' {
    $package_ensure = $gitlab::ensure
    $vcs_ensure = 'present'
    $directory_ensure = 'directory'

  } else {

    $package_ensure = 'purged'
    $vcs_ensure = 'absent'
    $directory_ensure = 'absent'

  }

  define create_directory {
    file { $title:
      ensure  => $directory_ensure,
      path    => "${gitlab::gitlab_home}/$title",
      owner   => $gitlab::gitlab_user,
      group   => $gitlab::gitlab_group,
      mode    => 'g+rx',
    }
  }

  # action
  package { $gitlab::package:
    ensure => $package_ensure,
  }

  # Clone GitLab code
  vcsrepo { 'GitLab dir':
    ensure    => $vcs_ensure,
    path      => "${gitlab::gitlab_home}/gitlab",
    provider  => 'git',
    source    => $gitlab::params::gitlab_source_url,
    revision  => $gitlab::gitlab_version,
    user      => $gitlab::gitlab_user,
  }
  #Create all necessary directories
  create_directory { $gitlab::params::gitlab_dirs: }
}
