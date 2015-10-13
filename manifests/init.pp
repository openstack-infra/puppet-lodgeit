# == Class: lodgeit
#
class lodgeit {

  include lodgeit::params

  include ::httpd
  include ::pip

  # The httpd module supports only Debian/Ubuntu (requires a2enmod)
  # On EL7 derivative both of those modules are part of the httpd package
  # Hence there is no need for extra action
  if $::osfamily == 'Debian' {
    httpd_mod { ['proxy', 'proxy_http'] :
      ensure => present,
    }
  }

  package { $::lodgeit::params::system_packages:
    ensure => present,
  }

  if ! defined(Package[$::lodgeit::params::mysql_python_package]) {
    package { $::lodgeit::params::mysql_python_package:
      ensure   => present,
    }
  }

  package { 'SQLAlchemy':
    ensure   => present,
    provider => pip,
    require  => Class[pip],
  }

  file { '/srv/lodgeit':
    ensure => directory,
  }

  vcsrepo { '/tmp/lodgeit-main':
    ensure   => latest,
    provider => git,
    source   => 'https://git.openstack.org/openstack-infra/lodgeit',
  }

  if $::osfamily == 'RedHat' {

    file { '/etc/systemd/system/lodgeit@.service':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///modules/lodgeit/lodgeit.service',
    } ~>
    exec { '/bin/systemctl daemon-reload' : }

  }


}
