# == Class: gitlab::gpg_key
#
# This class exists to
# 1. Add Michal Papis gpg key (required for rvm installation)
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
# * {A puppet module for installing and using RVM}[https://forge.puppetlabs.com/maestrodev/rvm]
#
#
# === Authors
#
# * Evgeniy Evtushenko <mailto:evgeniye@crytek.com>
#
class gitlab::gpg_key {
  # Adding Michal Papis gpg key to prevent next error message:
  # "gpg: Can't check signature: No public key"
  exec { 'Add Michal Papis gpg key':
    command => 'gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3',
    path    => '/usr/bin',
    creates => '/root/.gnupg/trustdb.gpg',
  } 
}
