require 'rails_helper'

RSpec.describe Contact do
  describe 'phone validation', db: false do
    let(:contact) { described_class.new }

    it 'rejects absent' do
      contact.phone = nil
      contact.validate
      expect(contact.errors).to have_key(:phone)
    end

    it 'rejects invalid format' do
      contact.phone = '123'
      contact.validate
      expect(contact.errors).to have_key(:phone)
    end

    it 'rejects all zeros in country code' do
      contact.phone = '+000.1'
      contact.validate
      expect(contact.errors).to have_key(:phone)
    end

    it 'rejects all zeros in phone number' do
      contact.phone = '+123.0'
      contact.validate
      expect(contact.errors).to have_key(:phone)
    end

    it 'accepts valid' do
      contact.phone = '+123.4'
      contact.validate
      expect(contact.errors).to_not have_key(:phone)
    end
  end
end
