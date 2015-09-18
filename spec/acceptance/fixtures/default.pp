class { '::lodgeit': }

lodgeit::site { 'acceptance':
  db_password => '123456',
  port        => 8080,
}
