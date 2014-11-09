# == Class: gitlab::repo
#
# This class exists to coordinate all repository related actions, functionality
# and logical units in a central place.
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
#   class { 'gitlab::repo': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Evgeniy Evtushenko <mailto:evgeniye@crytek.com>
#
class gitlab::repo {
  #### Repository management

  # YUM repository. See 'yumrepo' doc at http://j.mp/gtCgFw for information.
  $repo_enabled = $gitlab::ensure ? {
    # Removal of the repository file itself is currently not supported, (cf.
    # http://j.mp/w7fA20). 'absent' just removes the 'enabled=0/1' line
    # from the .repo file.
    'present' => 1,
    'absent'  => 0,
  }

  # Add RPMForge-extras repository for newest git package
  yumrepo { 'rpmforge-extras':
    enabled   => $repo_enabled,
    baseurl   => "http://apt.sw.be/redhat/el6/en/${::architecture}/extras",
    descr     => 'RHEL $releasever - RPMforge.net - extras',
    gpgkey    => 'http://apt.sw.be/RPM-GPG-KEY.dag.txt',
    gpgcheck  => 1,
  }

}
