require 'rails_helper'

RSpec.describe Contact::Ident::MismatchValidator do
  describe '::mismatches' do
    it 'returns mismatches' do
      mismatches = [
        Contact::Ident::MismatchValidator::Mismatch.new('birthday', Country.new('EE'))
      ]

      expect(described_class.mismatches).to eq(mismatches)
    end
  end
end
