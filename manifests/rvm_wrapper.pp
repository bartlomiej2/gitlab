# == Class: gitlab::rvm_wrapper
#
# This class exists to
# 1. Install Ruby Package Manager (by maestrodev-rvm module)
# 2. Install newer version of ruby than persists in repository
# 3. Set users which will be able to use newer version of ruby
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
class gitlab::rvm_wrapper {
  # import class with FIX required to rvm installation
  class { 'gitlab::gpg_key': }
  # Install Ruby Version Manager (RVM)
  class { 'rvm': }

  # FIX should be applied before rvm installation
  Class['gitlab::gpg_key'] -> Class['rvm']

  # install newer ruby version (binary)
  rvm_system_ruby {
    "ruby-${gitlab::params::ruby_version}":
      ensure      => $gitlab::ensure,
      default_use => true,
      build_opts  => ['--binary'],
      require	  => Class[ 'rvm' ],
  }
  # Set users which will be able to use newest version of ruby
  rvm::system_user { "${gitlab::gitlab_user}": ; }
}

class gitlab::gpg_key {
  # FIX
  # Adding Michal Papis gpg key to prevent error message
  # during rvm installation:
  # "gpg: Can't check signature: No public key"
  exec { 'GPGkey':
    command => 'gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3',
    path    => '/usr/bin',
    creates => '/root/.gnupg/trustdb.gpg',
  }
}
