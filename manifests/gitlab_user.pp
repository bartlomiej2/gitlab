# == Class: gitlab::gitlab_user
#
# This class exists to
# 1. Add git system user
# 2. Make git homefolder readable for group git
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
class gitlab::gitlab_user {
  # User 'git' is used by GitLab
  user { 'gitlab_user':
    ensure	=> $gitlab::ensure,
    name        => $gitlab::gitlab_user,
    #shell       => '/sbin/nologin',
    home	=> $gitlab::gitlab_home,
    comment	=> 'GitLab',
    managehome	=> true,
  }

  # Make /home/git readable for group 'git'. This allows
  # get access to the git homefolder for nginx user.
  file { 'GitLab home directory':
    path    => $gitlab::gitlab_home,
    mode    => 'g+rX',
    require => User[ 'gitlab_user' ],
  }
}
