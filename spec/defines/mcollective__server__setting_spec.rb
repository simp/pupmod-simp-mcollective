require 'spec_helper'

describe 'mcollective::server::setting' do
  let :facts do
    {
      puppetversion: Puppet.version,
      facterversion: Facter.version,
      macaddress: '00:00:00:26:28:8a',
      osfamily: 'RedHat',
      operatingsystem: 'CentOS',
      mco_version: '2.8.4',
      path: ['/usr/bin', '/usr/sbin'],
    }
  end
  context 'some_setting' do
    let(:title) { 'some_setting' }
    let(:params) { { 'value' => 'pie' } }
    it { should contain_mcollective__setting('mcollective::server::setting some_setting') }
    it { should contain_mcollective__setting('mcollective::server::setting some_setting').with_setting('some_setting') }
    it { should contain_mcollective__setting('mcollective::server::setting some_setting').with_value('pie') }
    it { should contain_mcollective__setting('mcollective::server::setting some_setting').with_target('mcollective::server') }
  end
end
