# == Class: gitlab::cvs
#
# This class exists to
# 1. Clone GitLab repo
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
  } else {
    $vcs_ensure = 'absent'
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

}
