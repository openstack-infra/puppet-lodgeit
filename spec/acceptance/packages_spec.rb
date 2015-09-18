require 'spec_helper_acceptance'

describe 'required packages', :if => ['debian', 'ubuntu'].include?(os[:family]) do
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
