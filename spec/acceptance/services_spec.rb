require 'spec_helper_acceptance'

describe 'required services' do
  describe service('acceptance-paste') do
    it { should be_running }
    it { should be_enabled }
  end

  describe command('curl --verbose http://localhost:8080') do
    its(:stdout) { should include 'Acceptance Pastebin' }
  end
end
