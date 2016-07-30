require 'spec_helper'

describe 'mcollective::user' do
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
  let(:title) { 'nagios' }
  let(:default_params) { { connector: 'activemq', middleware_hosts: ['localhost'], ssl_ciphers: nil } }
  let(:params) { default_params }
  it { should contain_file('/home/nagios/.mcollective.d') }
  it { should contain_file('mcollective::user nagios').with_path('/home/nagios/.mcollective') }

  describe '#securityprovider' do
    context 'ssl' do
      let(:params) { default_params.merge(securityprovider: 'ssl') }
      it { should contain_file('/home/nagios/.mcollective.d/credentials/certs/nagios.pem') }
      it { should contain_file('/home/nagios/.mcollective.d/credentials/private_keys/nagios.pem') }
      it { should contain_mcollective__user__setting('nagios:plugin.ssl_client_public') }
      it { should contain_mcollective__user__setting('nagios:plugin.ssl_client_public').with_value('/home/nagios/.mcollective.d/credentials/certs/nagios.pem') }
      it { should contain_mcollective__user__setting('nagios:plugin.ssl_client_private') }
      it { should contain_mcollective__user__setting('nagios:plugin.ssl_server_public') }
    end

    context 'pies' do
      let(:params) { default_params.merge(securityprovider: 'pies') }
      it { should_not contain_file('/home/nagios/.mcollective.d/credentials/certs/nagios.pem') }
      it { should_not contain_mcollective__user__setting('nagios:plugin.ssl_client_public') }
      it { should_not contain_mcollective__user__setting('nagios:plugin.ssl_client_private') }
      it { should_not contain_mcollective__user__setting('nagios:plugin.ssl_server_public') }
    end
  end

  describe '#middleware_ssl' do
    context 'true and "true"' do
      [true, 'true',].each do |value|
        let(:params) { default_params.merge(middleware_ssl: value) }
        it { should contain_file('/home/nagios/.mcollective.d/credentials/private_keys/nagios.pem') }
        it { should contain_mcollective__user__setting('nagios plugin.activemq.pool.1.ssl.cert') }
        it { should contain_mcollective__user__setting('nagios plugin.activemq.pool.1.ssl.cert').with_value('/home/nagios/.mcollective.d/credentials/certs/nagios.pem') }
      end
    end

    context 'false' do
      let(:params) { default_params.merge(middleware_ssl: false) }
      it { should_not contain_mcollective__user__setting('nagios plugin.activemq.pool.1.ssl.cert') }
    end
  end
end
