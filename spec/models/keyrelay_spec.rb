require 'rails_helper'

describe Keyrelay do
  before :example do
    Fabricate(:zonefile_setting, origin: 'ee')
  end

  context 'with invalid attribute' do
    before :example do
      @keyrelay = Keyrelay.new
    end

    it 'should not be valid' do
      @keyrelay.valid?
      @keyrelay.errors.full_messages.should match_array([
        "Auth info pw Password is missing",
        "Domain is missing",
        "Key data alg Algorithm is missing",
        "Key data flags Flag is missing",
        "Key data protocol Protocol is missing",
        "Key data public key Public key is missing",
        "Only one parameter allowed: relative or absolute"
      ])
    end

    it 'should not have any versions' do
      @keyrelay.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :example do
      @keyrelay = Fabricate(:keyrelay)
    end

    it 'should be valid' do
      @keyrelay.valid?
      @keyrelay.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @keyrelay = Fabricate(:keyrelay)
      @keyrelay.valid?
      @keyrelay.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @keyrelay.versions.should == []
        @keyrelay.auth_info_pw = 'newpw'
        @keyrelay.save
        @keyrelay.errors.full_messages.should match_array([])
        @keyrelay.versions.size.should == 1
      end
    end

    it 'is in pending status' do
      @keyrelay.status.should == 'pending'
    end
  end

  it 'is in expired status' do
    kr = Fabricate(:keyrelay, pa_date: Time.zone.now - 2.weeks)
    expect(kr.status).to eq('expired')
  end

  it 'does not accept invalid relative expiry' do
    kr = Fabricate.build(:keyrelay, expiry_relative: 'adf')
    expect(kr.save).to eq(false)
    expect(kr.errors[:expiry_relative].first).to eq('Expiry relative must be compatible to ISO 8601')
  end
end
