require 'rails_helper'

RSpec.describe Account do
  describe 'registrar validation', db: false do
    subject(:account) { described_class.new }

    it 'rejects absent' do
      account.registrar = nil
      account.validate
      expect(account.errors).to have_key(:registrar)
    end
  end
end
