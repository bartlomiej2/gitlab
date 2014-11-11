# == Class: gitlab::cvs
#
# This class exists to
# 1. Clone GitLab repo
# 2. Create all necessary directories
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
class gitlab::cvs_repo {

  if $gitlab::ensure == 'present' {
    $vcs_ensure = 'present'
    $directory_ensure = 'directory'
  } else {
    $vcs_ensure = 'absent'
    $directory_ensure = 'absent'
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

  define create_directory {
    file { $title:
      ensure  => $directory_ensure,
      path    => "${gitlab::gitlab_home}/$title",
      owner   => $gitlab::gitlab_user,
      group   => $gitlab::gitlab_group,
      mode    => 'g+rx',
    }
  }

  #Create all necessary directories
  create_directory { $gitlab::params::gitlab_dirs: }

}
