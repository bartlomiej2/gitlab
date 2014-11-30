# == Class: gitlab
#
# This module allows you to manage a GitLab intance with Puppet.
#
# GitLab offers git repository management, code reviews, issue tracking,
# activity feeds, wikis. The puppet-gitlab module allows you to manage
# GitLab installation with all required dependencies. The modulle provides
# some options which allow you to customize installation.
#
#
# === Parameters
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>. If set to <tt>absent</tt>:
#   * The managed software packages are being uninstalled.
#   * Any traces of the packages will be purged as good as possible. This may
#     include existing configuration files. The exact behavior is provider
#     dependent. Q.v.:
#     * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
#     * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   * System modifications (if any) will be reverted as good as possible
#     (e.g. removal of created users, services, changed log settings, ...).
#   * This is thus destructive and should be used with care.
#   Defaults to <tt>present</tt>.
#
# [*status*]
#   String to define the status of the service. Possible values:
#   * <tt>enabled</tt>: Service is running and will be started at boot time.
#   * <tt>disabled</tt>: Service is stopped and will not be started at boot
#     time.
#   * <tt>running</tt>: Service is running but will not be started at boot time.
#     You can use this to start a service on the first Puppet run instead of
#     the system startup.
#   * <tt>unmanaged</tt>: Service will not be started at boot time and Puppet
#     does not care whether the service is running or not. For example, this may
#     be useful if a cluster management software is used to decide when to start
#     the service plus assuring it is running on the desired node.
#   Defaults to <tt>enabled</tt>. The singular form ("service") is used for the
#   sake of convenience. Of course, the defined status affects all services if
#   more than one is managed (see <tt>service.pp</tt> to check if this is the
#   case).
#
# [*package*]
#   The default value to define which packages are managed by this module gets
#   set in gitlab::params. This parameter is able to overwrite the default.
#   Just specify your own package list as a {Puppet array}[http://j.mp/wzu7L3].
#   However, usage of this feature is <b>not recommended</b> in order to keep
#   the node definitions maintainable. It exists for <b>exceptional cases
#   only</b>.
#
# [*user*]
#   The default value to define name of system user used for GitLab. Defaults to
#   <tt>git</tt>
#
# [*gitlab_group*]
#
# [*gitlab_home*]
#
# [*gitlab_version*]
#
# [*redis_address*]
#
# [*redis_port*]
#
# [*unicorn_address*]
#
# [*unicorn_port*]
#
#
# The default values for the parameters are set in gitlab::params. Have
# a look at the corresponding <tt>params.pp</tt> manifest file if you need more
# technical information about them.
#
#
# === Examples
#
# * Installation:
#     class { 'gitlab': }
#
# * Removal/decommissioning:
#     class { 'gitlab':
#       ensure => 'absent',
#     }
#
# * Run installation with enabled debugging:
#     class { 'gitlab':
#       debug => true,
#     }
#
#
# === Authors
#
# * Evgeniy Evtushenko <mailto:evgeniye@crytek.com>
#
class gitlab(
  $ensure	    = $gitlab::params::ensure,
  $status	    = $gitlab::params::status,
  $package          = $gitlab::params::package,
  $gitlab_user	    = $gitlab::params::gitlab_user,
  $gitlab_group	    = $gitlab::params::gitlab_group,
  $gitlab_home	    = $gitlab::params::gitlab_home,
  $gitlab_version   = $gitlab::params::gitlab_version,
  $gitlab_address   = $gitlab::params::gitlab_address,
  $redis_address    = $gitlab::params::redis_address,
  $redis_port	    = $gitlab::params::redis_port,
  $unicorn_address  = $gitlab::params::unicorn_address,
  $unicorn_port     = $gitlab::params::unicorn_port,
  $ruby_version	    = undef

) inherits gitlab::params {

  #### Validate parameters

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  # check ruby version
  if($ruby_version == undef) {
    fail('
      Parametr ruby_version is not set.
      Please set correct version of ruby that you installed with RVM. For example:
      class { "gitlab": ruby_version => "2.1.2", }'
    )
  }

  # package list
  if !is_array($package) or empty($package) {
    fail('"package" parameter must be an array of package names, containing at least one element')
  }


  #### Manage actions

  class { 'gitlab::repo': }	    # repository
  class { 'gitlab::package': }	    # package(s)
  class { 'gitlab::config': }	    # configuration
  class { 'gitlab::service': }	    # service
  class { 'gitlab::user': }	    # system user
  class { 'gitlab::database': }	    # database
  class { 'gitlab::cvs_repo': }	    # GitLab repository
  class { 'gitlab::directories': }  # GitLab repository
  class { 'gitlab::setup': }	    # gitlab
  class { 'gitlab::proxy': }	    # apache reverse-proxy for gitlab

  #### Manage relationships

  if $ensure == 'present' {
    Class['gitlab::user'] ->	    # Add system user for GitLab
    Class['gitlab::repo'] ->	    # Add repositories
    Class['gitlab::package'] ->	    # Then install packages
    Class['gitlab::cvs_repo'] ->    # Add repositories
    Class['gitlab::directories'] -> # Create directories and set owner/mode
    Class['gitlab::database'] ->    # Create database
    Class['gitlab::config'] ->	    # Generate configuration files
    Class['gitlab::setup'] ->	    # Install GitLab (exec actions)
    Class['gitlab::service'] ->	    # Enable service
    Class['gitlab::proxy']	    # Configure apache as reverse-proxy for GitLab

  } else {
    # there is currently no need for a specific removal order
  }

}
