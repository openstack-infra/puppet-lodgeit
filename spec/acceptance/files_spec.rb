require 'spec_helper_acceptance'

describe 'required files', :if => ['debian', 'ubuntu'].include?(os[:family]) do
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
