class { '::mysql::server':
  config_hash => { 'root_password' => '123456' },
}

mysql::db { 'acceptance':
  user     => 'acceptance',
  password => '123456',
  host     => 'localhost',
  grant    => ['all'],
  require  => Class['mysql::server'],
}
