require 'spec_helper'

describe 'mcollective::actionpolicy' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context 'dummy' do
          let(:title) { 'dummy' }
          it { should contain_datacat('mcollective::actionpolicy dummy') }
        end
      end
    end
  end
end
