# == Class: gitlab::gitlab_setup
#
# This class exists to
# 1. Clone GitLab repo
# 2. Copy Rack attack confid
# 3. Create directory for sattelites
# 4. Execute commands:
#   a. Install gems
#   b. Install GitLab-shell
#   c. Initialize database
#   d. Install assets
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

  # Copy the example Rack attack config
  file { 'GitLab rack_attack config':
    ensure  => $gitlab::ensure,
    path    => "${gitlab::gitlab_home}/gitlab/config/initializers/rack_attack.rb",
    source  => "${gitlab::gitlab_home}/gitlab/config/initializers/rack_attack.rb.example",
    owner   => $gitlab::gitlab_user,
    group   => $gitlab::gitlab_group,
  }

  define run_exec_bundle () {
    exec { $title:
      command => $title,
      creates => "${gitlab::gitlab_home}/gitlab/.puppet_bundle_exec.lock",
      cwd     => "${gitlab::gitlab_home}/gitlab",
      path    => [
	'/usr/local/rvm/gems/ruby-2.1.2/bin',
        '/usr/local/rvm/gems/ruby-2.1.2@global/bin',
        '/usr/local/rvm/rubies/ruby-2.1.2/bin',
        '/bin',
        '/usr/bin' ],
      timeout => 0,
      user    => $gitlab::gitlab_user,
    }
  }

  $bundle_exec_commands = [
    'bundle install --deployment --without development test mysql aws',
    "bundle exec rake gitlab:shell:install[v2.0.0] REDIS_URL=redis://${::gitlab::redis_address}:${::gitlab::redis_port} RAILS_ENV=production",
    'echo yes | bundle exec rake gitlab:setup RAILS_ENV=production',
    'bundle exec rake assets:precompile RAILS_ENV=production'
  ]

  run_exec_bundle { $bundle_exec_commands: } ->
  # Create lock-file to prevent repeat of bundle execution
  file { 'GitLab bundle exec lock':
    ensure  => $gitlab::ensure,
    path    => "${gitlab::gitlab_home}/gitlab/.puppet_bundle_exec.lock",
    owner   => $gitlab::gitlab_user,
    group   => $gitlab::gitlab_group,
  }

  gitlab::config::generate_config { $gitlab::params::gitlab_shell_config_files:
    confdir => "${gitlab::gitlab_home}/gitlab-shell",
  }


#  # GitLab-shell config file
#  file { 'Generate gitlab-shell config':
#    ensure  => $gitlab::ensure,
#    path    => "${gitlab::gitlab_home}/gitlab-shell/config.yml",
#    content => template("${module_name}/config.yml.erb"),
#    owner   => $gitlab::gitlab_user,
#    owner   => $gitlab::gitlab_group,
#    #require => Exec['Install GitLab Shell'],
#  }


#  # Install gems
#  exec { 'Install GitLab gems':
#    command => 'bundle install --deployment --without development test mysql aws',
#    #creates => '/home/git/gitlab/.puppet_exec_install_gitlab_gems.lock',
#    creates => '/home/git/gitlab/vendor/bundle/ruby/2.1.0/build_info/wikicloth-0.8.1.info',
#    cwd     => '/home/git/gitlab',
#    path    => [    '/usr/local/rvm/gems/ruby-2.1.2/bin',
#      '/usr/local/rvm/gems/ruby-2.1.2@global/bin',
#      '/usr/local/rvm/rubies/ruby-2.1.2/bin',
#      '/bin',
#      '/usr/bin'
#      ],
#    require => [ Package[ 'libicu-devel', 'cmake', 'postgresql-devel' ], Vcsrepo[ 'GitLab dir' ] ],
#    timeout => 0,
#    user    => $gitlab::gitlab_user,
#  }
#
#  # Lock file to prevent repeat of execution Exec['Install GitLab gems']
#  #file { '/home/git/gitlab/.puppet_exec_install_gitlab_gems.lock':
#  #  ensure  => $gitlab::ensure,
#  #  owner   => $gitlab::gitlab_user,
#  #  owner   => $gitlab::gitlab_group,
#  #  require => Exec['Install GitLab gems'],
#  #}
#
#  # Install GitLab Shell
#  exec { 'Install GitLab Shell':
#    command => "bundle exec rake gitlab:shell:install[v2.0.0] REDIS_URL=redis://${::gitlab::redis_address}:${::gitlab::redis_port} RAILS_ENV=production",
#    creates => '/home/git/gitlab-shell/Gemfile.lock',
#    cwd     => '/home/git/gitlab',
#    path    => [  '/usr/local/rvm/gems/ruby-2.1.2/bin',
#      '/usr/local/rvm/gems/ruby-2.1.2@global/bin',
#      '/usr/local/rvm/rubies/ruby-2.1.2/bin',
#      '/bin',
#      '/usr/bin'
#      ],
#    timeout => 0,
#    user    => 'git',
#    require => Vcsrepo[ 'GitLab dir' ],
#  }

#  # Initialize GitLab database
#  exec { 'Initialize GitLab Database':
#    command => 'echo yes | bundle exec rake gitlab:setup RAILS_ENV=production',
#    creates => '/home/git/gitlab/.puppet_exec_initialize_gitlab_database.lock',
#    cwd     => '/home/git/gitlab',
#    path    => [    '/usr/local/rvm/gems/ruby-2.1.2/bin',
#      '/usr/local/rvm/gems/ruby-2.1.2@global/bin',
#      '/usr/local/rvm/rubies/ruby-2.1.2/bin',
#      '/bin',
#      '/usr/bin'
#      ],
#    require => [ Package[ 'libicu-devel', 'cmake', 'postgresql-devel' ], Vcsrepo[ 'GitLab dir' ] ],
#    timeout => 0,
#    user    => 'git',
#  }
#  # default credantials are: root / 5iveL!fe
#
#  # Lock file to prevent repeat of execution Exec['Initialize GitLab Database']
#  file { '/home/git/gitlab/.puppet_exec_initialize_gitlab_database.lock':
#    ensure  => $gitlab::ensure,
#    path    => "${gitlab::gitlab_home}/",
#    owner   => $gitlab::gitlab_user,
#    owner   => $gitlab::gitlab_group,
#    require => Exec['Initialize GitLab Database'],
#  }
#
#  # Compile Assets
#  exec { 'Compile Assets':
#  command => 'bundle exec rake assets:precompile RAILS_ENV=production',
#  creates => '/home/git/gitlab/public/assets/',
#  cwd     => '/home/git/gitlab',
#  path    => [    '/usr/local/rvm/gems/ruby-2.1.2/bin',
#    '/usr/local/rvm/gems/ruby-2.1.2@global/bin',
#    '/usr/local/rvm/rubies/ruby-2.1.2/bin',
#    '/bin',
#    '/usr/bin'
#    ],
#  require => [
#    Package[ 'libicu-devel', 'cmake', 'postgresql-devel' ],
#    Vcsrepo[ 'GitLab dir' ],
#    Exec['Initialize GitLab Database']
#    ],
#  timeout => 0,
#  user    => 'git',
#  }      
      
}     
