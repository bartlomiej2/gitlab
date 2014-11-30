# == Class: gitlab::proxy
#
# This class exists to
# 1. Install redis package (by fsalum-redis module)
# 2. Configure redis instance (required for GitLab)
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
# * {GitLab recipes: Apache 2 RHEL6/CentOS6 recommendations}[https://gitlab.com/gitlab-org/gitlab-recipes/tree/master/web-server/apache]
# * {gitlab-ssl-apache2.4.conf}[https://gitlab.com/gitlab-org/gitlab-recipes/blob/master/web-server/apache/gitlab-ssl-apache2.4.conf]
#
#
# === Authors
#
# * Evgeniy Evtushenko <mailto:evgeniye@crytek.com>
#
class gitlab::proxy {

  $ssl_cert_file  = '/etc/httpd/ssl/gitlab.crt'
  $ssl_key_file	  = '/etc/httpd/ssl/gitlab.key'

  # SSL directory
  file { '/etc/httpd/ssl':
    ensure  => directory,
    owner   => $http_user,
    group   => $http_group,
    mode    => '0750',
  } ->
  # Generate self-signed ssl cert
  exec { 'Generate self-signed ssl cert':
    command => "openssl req -batch -newkey rsa:2048 -x509 -nodes -days 3560 -out $ssl_cert_file -keyout $ssl_key_file",
    creates => $ssl_cert_file,
    path    => [ '/usr/bin' ],
  } ->
  # Make cer and key readable only for apache user
  file { $ssl_cert_file:
    owner   => $http_user,
    group   => $http_group,
    mode    => '0640',
  } ->
  file { $ssl_key_file:
    owner   => $http_user,
    group   => $http_group,
    mode    => '0640',
  } ->

  # Create apache vhost for GitLab (redirects http => https)
  apache::vhost { 'gitlab':
    servername      => $gitlab::gitlab_address,
    port            => '80',
    docroot	    => "${gitlab::gitlab_home}/gitlab/public",
    redirect_status => 'permanent',    
    redirect_dest   => "https://${gitlab::gitlab_address}",
  } ->

  # Create apache vhost for GitLab
  apache::vhost { 'gitlab-ssl':
    ssl			=> true,
    ssl_cert        	=> $ssl_cert_file,
    ssl_key         	=> $ssl_key_file,

    servername		=> $gitlab::gitlab_address,
    port	      	=> '443',

    proxy_preserve_host	=> true,
    proxy_dest		=> "http://${gitlab::unicorn_address}:${gitlab::unicorn_port}",
    no_proxy_uris	=> [ "/uploads", "/assets" ],

    # apache equivalent of nginx try files
    # http://serverfault.com/questions/290784/what-is-apaches-equivalent-of-nginxs-try-files
    # http://stackoverflow.com/questions/10954516/apache2-proxypass-for-rails-app-gitlab
    rewrites => [
      {
	rewrite_cond  => [ '%{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f' ],
      	rewrite_rule   => [ ".* http://${gitlab::unicorn_address}:${gitlab::unicorn_port}%{REQUEST_URI} [P,QSA]" ],
      },
    ],
    request_headers 	=> [ "set X_FORWARDED_PROTO 'https'", ],

    # needed for downloading attachments
    docroot	      	=> "${gitlab::gitlab_home}/gitlab/public",
    manage_docroot    	=> false,

    # set up apache error documents, if back end goes down (i.e. 503 error) then a maintenance/deploy page is thrown up.
    error_documents => [
      { 'error_code' => '404',
	'document'   => '/404.html',
      },
      { 'error_code' => '422',
	'document'   => '/422.html',
      },
      { 'error_code' => '500',
	'document'   => '/500.html',
      },
      { 'error_code' => '503',
	'document'   => '/deploy.html',
      },
    ],

    # logs
    error_log_file	=> 'gitlab-ssl_error.log',
    access_log_file 	=> 'gitlab-ssl_access.log',
    directories		=> [
      {  path            => '/',
	 passenger_enabled => "off",
         options         => ['None'],
         allow           => 'from All',
         allow_override  => ['None'],
         order           => 'Allow,Deny',
      },
    ],
  }

}
