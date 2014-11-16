# == Class: gitlab::directories
#
# This class exists to
# 1. Create all necessary directories
# 2. Set ownership and access mode on log and tmp directories
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
class gitlab::directories {

  if $gitlab::ensure == 'present' {
    $directory_ensure = 'directory'
  } else {
    $directory_ensure = 'absent'
  }

  define create_directory {
    file { $title:
      ensure  => $directory_ensure,
      path    => "${gitlab::gitlab_home}/$title",
      owner   => $gitlab::gitlab_user,
      group   => $gitlab::gitlab_group,
      mode    => 'g+rwx,o-rwx',
    }
  }

  define directory_access_rights {
    file { $title:
      ensure  => $directory_ensure,
      path    => "${gitlab::gitlab_home}/$title",
      owner   => $gitlab::gitlab_user,
      group   => $gitlab::gitlab_group,
      mode    => '0775',
    }
  }

  # Create all necessary directories
  create_directory { $gitlab::params::gitlab_dirs: }

  # Set ownership and access mode on log and tmp directories
  directory_access_rights { 'gitlab/log': }
  directory_access_rights { 'gitlab/tmp': }

}
