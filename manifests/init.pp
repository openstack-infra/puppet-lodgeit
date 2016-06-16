# == Class: lodgeit
#
class lodgeit {
  $packages = [ 'python-imaging',
                'python-jinja2',
                'python-pybabel',
                'python-werkzeug',
                'python-simplejson',
                'python-pygments']

  include ::httpd

  include ::pip
  httpd_mod { 'proxy':
    ensure => present,
  }
  httpd_mod { 'proxy_http':
    ensure => present,
  }

  package { $packages:
    ensure => present,
  }

  if ! defined(Package['python-mysqldb']) {
    package { 'python-mysqldb':
      ensure   => present,
    }
  }

  package { 'SQLAlchemy':
    ensure   => present,
    provider => openstack_pip,
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

}
