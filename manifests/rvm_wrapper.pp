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
  ## Adding Michal Papis gpg key to prevent next error message:
  ## "gpg: Can't check signature: No public key"
  #exec { 'GPGkey':
  #  command => 'gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3',
  #  path    => '/usr/bin',
  #  creates => '/root/.gnupg/trustdb.gpg',
  #}
  # Code above moved to separate class: gitlab::gpg_key

  # Install Ruby Version Manager (RVM)
  contain rvm

  # install newer ruby version (binary)
  rvm_system_ruby {
    "ruby-${gitlab::params::ruby_version}":
      ensure      => $gitlab::ensure,
      default_use => true,
      build_opts  => ['--binary'],
  }
  # Set users which will be able to use newest version of ruby
  rvm::system_user { "${gitlab::gitlab_user}": ; }
}

