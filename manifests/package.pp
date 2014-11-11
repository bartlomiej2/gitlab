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
  } else {
    $package_ensure = 'purged'
  }

  # action
  package { $gitlab::package:
    ensure => $package_ensure,
  }

}
