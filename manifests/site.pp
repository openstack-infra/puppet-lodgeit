# == Define: site
#

define lodgeit::site(
  $port,
  $db_password,
  $db_host='localhost',
  $db_user=$name,
  $vhost_name="paste.${name}.org",
  $image=undef,
  $robotstxt=true,
) {

  include ::httpd

  ::httpd::vhost::proxy { $vhost_name:
    port            => 80,
    dest            => "http://localhost:${port}",
    require         => [File["/srv/lodgeit/${name}"], File['/srv/www/paste']],
    proxyexclusions => ['/robots.txt'],
    docroot         => "/srv/www/${name}/"
  }

  file { "/etc/init/${name}-paste.conf":
    ensure  => present,
    content => template('lodgeit/upstart.erb'),
    replace => true,
    require => Class['httpd'],
    notify  => Service["${name}-paste"],
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

  if $robotstxt {

    file { ['/srv/www', '/srv/www/paste']:
      ensure  => directory,
    }

    file { "/srv/www/paste/robots.txt":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/lodgeit/robots.txt',
      require => File['/srv/www/paste'],
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
    provider => upstart,
    require  => Class['httpd'],
  }
}
