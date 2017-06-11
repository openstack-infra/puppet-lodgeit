# == Define: site
#

define lodgeit::site(
  $db_password,
  $port,
  $db_host    = 'localhost',
  $db_name    = $name,
  $db_user    = $name,
  $image      = undef,
  $robotstxt  = true,
  $vhost_name = "paste.${name}.org",
) {

  include ::httpd

  ::httpd::vhost::proxy { $vhost_name:
    port            => 80,
    dest            => "http://localhost:${port}",
    require         => [File["/srv/lodgeit/${name}"], File["/srv/www/${name}"]],
    proxyexclusions => ['/robots.txt'],
    docroot         => "/srv/www/${name}/"
  }

  if versioncmp($::operatingsystemmajversion, '16.04') >= 0 {
    file { "/etc/systemd/system/${name}-paste.service":
      ensure  => present,
      content => template('lodgeit/systemd.erb'),
      replace => true,
      require => Class['httpd'],
      notify  => Service["${name}-paste"],
    }
  } else {
    file { "/etc/init/${name}-paste.conf":
      ensure  => present,
      content => template('lodgeit/upstart.erb'),
      replace => true,
      require => Class['httpd'],
      notify  => Service["${name}-paste"],
    }
  }

  file { "/srv/lodgeit/${name}":
    ensure  => directory,
    recurse => true,
    source  => '/tmp/lodgeit-main',
  }

  if $image != undef {
    file { "/srv/lodgeit/${name}/lodgeit/static/${image}":
      ensure => present,
      source => "puppet:///modules/lodgeit/${image}",
    }
  }

  file { "/srv/lodgeit/${name}/manage.py":
    ensure  => present,
    mode    => '0755',
    replace => true,
    content => template('lodgeit/manage.py.erb'),
    notify  => Service["${name}-paste"],
  }

  file { "/srv/lodgeit/${name}/lodgeit/views/layout.html":
    ensure  => present,
    replace => true,
    content => template('lodgeit/layout.html.erb'),
  }

  file { ['/srv/www', "/srv/www/${name}"]:
    ensure  => directory,
  }

  if $robotstxt {
    file { "/srv/www/${name}/robots.txt":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/lodgeit/robots.txt',
      require => File["/srv/www/${name}/"],
    }
  }
  cron { "update_backup_${name}":
    ensure => absent,
    user   => root,
  }

  mysql_backup::backup_remote { $name:
    database_host     => $db_host,
    database_user     => $db_user,
    database_password => $db_password,
  }

  service { "${name}-paste":
    ensure   => running,
    require  => Class['httpd'],
  }
}
