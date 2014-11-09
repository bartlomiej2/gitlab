# == Class: gitlab::config
#
# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
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
#   class { 'gitlab::config': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Evgeniy Evtushenko <mailto:evgeniye@crytek.com>
#
class gitlab::config {
  #### Configuration

  define generate_config ( $confdir = "${gitlab::gitlab_home}/gitlab/config" ) {
    file { $title:
      ensure  => $gitlab::ensure,
      path    => "${confdir}/${title}",
      content => template("${module_name}/${title}.erb"),
      owner   => $gitlab::gitlab_user,
      group   => $gitlab::gitlab_group,
    }
  }

  generate_config { $gitlab::params::gitlab_config_files: }

  # GitLab service config
  file { '/etc/default/gitlab':
    ensure  => $gitlab::ensure,
    owner   => $gitlab::gitlab_user,
    group   => $gitlab::gitlab_group,
    source  => "${gitlab::gitlab_home}/gitlab/lib/support/init.d/gitlab.default.example",
    #notify  => Service[$puppetmaster::params::service],
  }

  # GitLab service init-file
  file { '/etc/init.d/gitlab':
    ensure  => $gitlab::ensure,
    mode    => '+x',
    owner   => $gitlab::gitlab_user,
    group   => $gitlab::gitlab_group,
    source  => "${gitlab::gitlab_home}/gitlab/lib/support/init.d/gitlab",
    #notify  => Service[$puppetmaster::params::service],
  }

  # logrotate config for GitLab
  file { '/etc/logrotate.d/gitlab':
    ensure  => $gitlab::ensure,
    source  => "${gitlab::gitlab_home}/gitlab/lib/support/logrotate/gitlab",
    owner   => $gitlab::gitlab_user,
    group   => $gitlab::gitlab_group,
  }
}
