# === Class : lodgeit::params
class lodgeit::params {

  case $::osfamily {
    'RedHat' : {
      $system_packages = ['python-pillow',
                          'python-jinja2',
                          'python-babel',
                          'python-werkzeug',
                          'python-simplejson',
                          'python-pygments']

      $mysql_python_package = 'MySQL-python'
      $lodgeit_service_provider = undef

    }
    'Debian' : {
      $system_packages = ['python-imaging',
                          'python-jinja2',
                          'python-babel',
                          'python-werkzeug',
                          'python-simplejson',
                          'python-pygments']

      $mysql_python_package = 'python-mysqldb'
      $lodgeit_service_provider = 'upstart'
    }
    default : {
      fail("LodgeIt: The Operating System ${::osfamily} is not supported")
    }
  }

}
