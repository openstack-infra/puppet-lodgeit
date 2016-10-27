# == Define: site
#

define lodgeit::site(
  $db_password,
  $port,
  $db_host            = 'localhost',
  $db_name            = $name,
  $db_user            = $name,
  $expire_pastes_days = undef,
  $image              = undef,
  $robotstxt          = true,
  $vhost_name         = "paste.${name}.org",
) {

  include ::httpd

  ::httpd::vhost::proxy { $vhost_name:
    port            => 80,
    dest            => "http://localhost:${port}",
    require         => [File["/srv/lodgeit/${name}"], File["/srv/www/${name}"]],
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
    provider => upstart,
    require  => Class['httpd'],
  }

  if $expire_pastes_days {
    $ensure_expire = present
  } else {
    $ensure_expire = absent
  }

  file { '/usr/local/bin/expire_pastes.sh':
    ensure  => $ensure_expire,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('lodgeit/expire_pastes.sh.erb'),
  }

  cron { 'expire_pastes':
    ensure  => $ensure_expire,
    user    => 'root',
    weekday => '0',
    hour    => '0',
    minute  => '0',
    command => "/usr/local/bin/expire_pastes.sh ${expire_pastes_days} 2>&1 | logger -t expire_pastes",
    require => File['/usr/local/bin/expire_pastes.sh'],
  }
}
