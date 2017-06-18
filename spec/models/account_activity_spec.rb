require 'rails_helper'

RSpec.describe AccountActivity do
  describe 'account validation', db: false do
    subject(:account_activity) { described_class.new }

    it 'rejects absent' do
      account_activity.account = nil
      account_activity.validate
      expect(account_activity.errors).to have_key(:account)
    end
  end
end
