# == Class: gitlab::config
#
# FIXME/TODO Please check if you want to remove this class because it may be
#            unnecessary for your module. Don't forget to update the class
#            declarations and relationships at init.pp afterwards (the relevant
#            parts are marked with "FIXME/TODO" comments).
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

  # nothing right now

  # Helpful snippet(s):
  #
  # Config file. See 'file' doc at http://j.mp/wKju0C for information.
  # file { 'gitlab_config':
  #   ensure  => 'present',
  #   path    => '/etc/gitlab/gitlab.conf',
  #   mode    => '0644',
  #   owner   => 'root',
  #   group   => 'root',
  #   # If you specify multiple file sources for a file, then the first source
  #   # that exists will be used.
  #   source  => [
  #     "puppet:///modules/gitlab/config.cfg-$::fqdn",
  #     "puppet:///modules/gitlab/config.cfg-$::hostname",
  #     'puppet:///modules/gitlab/config.cfg'
  #   ],
  #   content => template('gitlab/config.erb'),
  # }

}
