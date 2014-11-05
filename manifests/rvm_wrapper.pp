# == Class: gitlab::rvm_wrapper
#
# This class exists to
# 1. Add Michal Papis gpg key (required for rvm installation)
# 2. Install Ruby Package Manager (by maestrodev-rvm module)
# 3. Install newer version of ruby than persists in repository
# 4. Set users which will be able to use newer version of ruby
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
  # Install Ruby Version Manager (RVM)
  include rvm

  # Adding Michal Papis gpg key to prevent next error message:
  # "gpg: Can't check signature: No public key"
  exec { 'Add Michal Papis gpg key':
    command => 'gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3',
    path    => '/usr/bin',
    creates => '/root/.gnupg/trustdb.gpg',
  }

  # install newer ruby version (binary)
  rvm_system_ruby {
    "ruby-${gitlab::params::ruby_version}":
      ensure      => $gitlab::ensure,
      default_use => true,
      build_opts  => ['--binary'],
      require	  => Exec[ 'Add Michal Papis gpg key' ],
  }
  # Set users which will be able to use newest version of ruby
  rvm::system_user { "${gitlab::gitlab_user}": ; }
}

