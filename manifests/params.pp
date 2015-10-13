# === Class : lodgeit::params
class lodgeit::params {

  $common_packages = ['python-jinja2',
                      'python-babel',
                      'python-werkzeug',
                      'python-simplejson',
                      'python-pygments']

  case $::osfamily {
    'RedHat' : {
      $system_packages = concat($common_packages, 'python-pillow')
      $mysql_python_package = 'MySQL-python'
      $lodgeit_service_provider = undef

    }
    'Debian' : {
      $system_packages = concat($common_packages, 'python-imaging')
      $mysql_python_package = 'python-mysqldb'
      $lodgeit_service_provider = 'upstart'
    }
    default : {
      fail("LodgeIt: The Operating System ${::osfamily} is not supported")
    }
  }

}
