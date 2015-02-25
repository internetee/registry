require 'rails_helper'

describe Certificate do
  it { should belong_to(:api_user) }

  context 'with invalid attribute' do
    before :all do
      @certificate = Certificate.new
    end

    it 'should not be valid' do
      @certificate.valid?
      @certificate.errors.full_messages.should match_array([
        "Csr is missing"
      ])
    end

    it 'should not have any versions' do
      @certificate.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :all do
      @certificate = Fabricate(:certificate)
    end

    it 'should be valid' do
      @certificate.valid?
      @certificate.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @certificate = Fabricate(:certificate)
      @certificate.valid?
      @certificate.errors.full_messages.should match_array([])
    end

    it 'should sign csr' do
      @certificate.status.should == 'unsigned'
      @certificate.sign!
      @certificate.status.should == 'signed'
      @certificate.crt.should_not be_blank
    end

    it 'should revoke crt' do
      @certificate.revoke!
      @certificate.status.should == 'revoked'
    end

    it 'should have one version' do
      with_versioning do
        @certificate.versions.should == []
        @certificate.csr = 'new_request'
        @certificate.save
        @certificate.errors.full_messages.should match_array([])
        @certificate.versions.size.should == 1
      end
    end
  end
end
