require 'rails_helper'

RSpec.describe Account do
  it 'has versions' do
    with_versioning do
      price = build(:account)
      price.save!
      expect(price.versions.size).to be(1)
    end
  end

  describe 'registrar validation', db: false do
    subject(:account) { described_class.new }

    it 'rejects absent' do
      account.registrar = nil
      account.validate
      expect(account.errors).to have_key(:registrar)
    end
  end
end
