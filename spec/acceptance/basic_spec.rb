require 'spec_helper_acceptance'

describe 'puppet-lodgeit module', :if => ['debian', 'ubuntu'].include?(os[:family]) do
  def pp_path
    base_path = File.dirname(__FILE__)
    File.join(base_path, 'fixtures')
  end

  def preconditions_puppet_module
    module_path = File.join(pp_path, 'preconditions.pp')
    File.read(module_path)
  end

  def default_puppet_module
    module_path = File.join(pp_path, 'default.pp')
    File.read(module_path)
  end

  before(:all) do
    apply_manifest(preconditions_puppet_module, catch_failures: true)
  end

  it 'should work with no errors' do
    apply_manifest(default_puppet_module, catch_failures: true)
  end

  it 'should be idempotent' do
    pending('this module is not idempotent yet')
    apply_manifest(default_puppet_module, catch_changes: true)
  end

  describe 'required files' do
    describe file('/srv/lodgeit') do
      it { should be_directory }
    end

    describe file('/tmp/lodgeit-main/.git') do
      it { should be_directory }
    end

    describe file('/srv/lodgeit/acceptance/.git') do
      it { should be_directory }
    end

    describe file('/etc/init/acceptance-paste.conf') do
      it { should be_file }
      its(:content) { should include 'exec python /srv/lodgeit/acceptance/manage.py runserver -h 127.0.0.1 -p 80' }
    end

    describe file('/srv/lodgeit/acceptance/lodgeit/static/header-bg2.png') do
      it { should be_file }
    end

    describe file('/srv/lodgeit/acceptance/manage.py') do
      it { should be_file }
      its(:content) { should include "dburi = 'mysql://acceptance:123456@localhost:3306/acceptance'" }
    end

    describe file('/srv/lodgeit/acceptance/lodgeit/views/layout.html') do
      it { should be_file }
      its(:content) { should include 'Acceptance Pastebin' }
    end
  end

  describe 'required packages' do
    required_packages = [
      package('python-imaging'),
      package('python-jinja2'),
      package('python-pybabel'),
      package('python-werkzeug'),
      package('python-simplejson'),
      package('python-pygments'),
      package('python-mysqldb'),
    ]

    required_packages.each do |package|
      describe package do
        it { should be_installed }
      end
    end

    describe package('SQLAlchemy') do
      it { should be_installed.by('pip') }
    end
  end

  describe 'required services' do
    describe service('acceptance-paste') do
      it { should be_running }
      it { should be_enabled }
    end

    describe command('curl --verbose http://localhost:8080') do
      its(:stdout) { should include 'Acceptance Pastebin' }
    end
  end

  describe cron do
    it { should have_entry('0 0 * * * /usr/bin/mysqldump --defaults-file=/root/.acceptance_db.cnf --opt --ignore-table mysql.event --all-databases | gzip -9 > /var/backups/mysql_backups/acceptance.sql.gz').with_user('root') }
  end
end
