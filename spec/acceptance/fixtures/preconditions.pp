class { '::mysql::server':
  root_password    => $mysql_root_password,
  override_options => {
    'mysqld' => {
      'default-storage-engine' => 'InnoDB',
    }
  }
}

mysql::db { 'acceptance':
  user     => 'acceptance',
  password => '123456',
  host     => 'localhost',
  grant    => ['all'],
  require  => Class['mysql::server'],
}
