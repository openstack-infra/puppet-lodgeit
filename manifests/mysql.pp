# == Class: puppet-lodgeit::mysql
#
class lodgeit::mysql(
  $mysql_root_password,
  $database_name = $name,
  $database_user = $name,
  $database_password,
) {
  class { '::mysql::server':
    config_hash => {
      'root_password'  => $mysql_root_password,
      'default_engine' => 'InnoDB',
      'bind_address'   => '127.0.0.1',
    }
  }
  include ::mysql::server::account_security

  mysql::db { $database_name:
    user     => $database_user,
    password => $database_password,
    host     => 'localhost',
    grant    => ['all'],
    charset  => 'utf8',
    require  => [
      Class['mysql::server'],
      Class['mysql::server::account_security'],
    ],
  }
}

