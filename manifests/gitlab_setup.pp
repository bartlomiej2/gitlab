# == Class: gitlab::gitlab_setup
#
# This class exists to
# 1. Copy Rack attack config
# 2. Execute commands:
#   a. Install gems
#   b. Install GitLab-shell
#   c. Initialize database
#   d. Install assets
# 3. Generate GitLab-shell config
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
class gitlab::gitlab_setup {
  $gitlab_dir = "${gitlab::gitlab_home}/gitlab"

  # Copy the example of Rack attack config
  file { 'Generate rack_attack config':
    ensure  => $gitlab::ensure,
    path    => "${gitlab_dir}/config/initializers/rack_attack.rb",
    source  => "${gitlab_dir}/config/initializers/rack_attack.rb.example",
    owner   => $gitlab::gitlab_user,
    group   => $gitlab::gitlab_group,
  }

  define run_exec_bundle () {
    exec { $title:
      command => $title,
      creates => "${gitlab_dir}/.puppet_bundle_exec.lock",
      cwd     => "${gitlab_dir}",
      path    => [
	"/usr/local/rvm/gems/ruby-${gitlab::params::ruby_version}/bin",
        "/usr/local/rvm/gems/ruby-${gitlab::params::ruby_version}@global/bin",
        "/usr/local/rvm/rubies/ruby-${gitlab::params::ruby_version}/bin",
        "/bin",
        "/usr/bin" ],
      timeout => 0,
      user    => $gitlab::gitlab_user,
    }
  }

  $bundle_cmd_install_gems = 'bundle install --deployment --without development test mysql aws'
  $bundle_cmd_install_gitlab_shell = "bundle exec rake gitlab:shell:install[v2.0.0] REDIS_URL=redis://${::gitlab::redis_address}:${::gitlab::redis_port} RAILS_ENV=production"
  $bundle_cmd_initialize_database = 'echo yes | bundle exec rake gitlab:setup RAILS_ENV=production'
  $bundle_cmd_compile_assets = 'bundle exec rake assets:precompile RAILS_ENV=production'

  # Execute bundle commands
  run_exec_bundle { $bundle_cmd_install_gems: } ->
  run_exec_bundle { $bundle_cmd_install_gitlab_shell: } ->
  run_exec_bundle { $bundle_cmd_initialize_database: } ->
  run_exec_bundle { $bundle_cmd_compile_assets: } ->

  # Create lock-file to prevent repeat of bundle execution
  file { 'GitLab bundle exec lock':
    ensure  => $gitlab::ensure,
    path    => "${gitlab_dir}/.puppet_bundle_exec.lock",
    owner   => $gitlab::gitlab_user,
    group   => $gitlab::gitlab_group,
  }->

  # Generate config for GitLab-shell
  gitlab::config::generate_config { $gitlab::params::gitlab_shell_config_files:
    confdir => "${gitlab::gitlab_home}/gitlab-shell",
  }

}     
