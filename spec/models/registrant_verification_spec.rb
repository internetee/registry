require 'rails_helper'

describe RegistrantVerification do
  before :example do
    Setting.ds_algorithm = 2
    Setting.ds_data_allowed = true
    Setting.ds_data_with_key_allowed = true
    Setting.key_data_allowed = true

    Setting.dnskeys_min_count = 0
    Setting.dnskeys_max_count = 9
    Setting.ns_min_count = 2
    Setting.ns_max_count = 11

    Setting.transfer_wait_time = 0

    Setting.admin_contacts_min_count = 1
    Setting.admin_contacts_max_count = 10
    Setting.tech_contacts_min_count = 0
    Setting.tech_contacts_max_count = 10

    Setting.client_side_status_editing_enabled = true

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
