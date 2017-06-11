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

  describe 'required services' do
    describe service('acceptance-paste') do
      it { should be_running }
      it { should be_enabled }
    end

    describe command('curl --verbose http://localhost:8080') do
      its(:stdout) { should include 'Acceptance Pastebin' }
    end
  end

end
