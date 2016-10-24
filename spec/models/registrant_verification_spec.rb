require 'rails_helper'

describe RegistrantVerification do
  before :example do
    Fabricate(:zonefile_setting, origin: 'ee')
  end
  context 'with invalid attribute' do
    before :example do
      @registrant_verification = RegistrantVerification.new
    end

    it 'should not be valid' do
      @registrant_verification.valid?
      @registrant_verification.errors.full_messages.should match_array([
        "Domain name is missing",
        "Verification token is missing",
        "Action is missing",
        "Action type is missing",
        "Domain is missing"
      ])
    end
  end

  context 'with valid attributes' do
    before :example do
      @registrant_verification = Fabricate(:registrant_verification)
    end

    it 'should be valid' do
      @registrant_verification.valid?
      @registrant_verification.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @registrant_verification = Fabricate(:registrant_verification)
      @registrant_verification.valid?
      @registrant_verification.errors.full_messages.should match_array([])
    end
  end
end
