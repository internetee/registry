require 'rails_helper'
require 'lib/e164_phone_number'

RSpec.describe Contact do
  let(:contact) { described_class.new }

  describe 'phone', db: false do
    it_behaves_like 'e164 phone number' do
      let(:model) { contact }
      let(:attribute) { :phone }
    end
  end

  describe 'phone validation', db: false do
    it 'rejects absent' do
      contact.phone = nil
      contact.validate
      expect(contact.errors).to be_added(:phone, :blank)
    end

    it 'rejects all zeros in country code' do
      contact.phone = '+000.1'
      contact.validate
      expect(contact.errors).to be_added(:phone, :invalid)
    end

    it 'rejects all zeros in subscriber number' do
      contact.phone = '+123.0'
      contact.validate
      expect(contact.errors).to be_added(:phone, :invalid)
    end

    it 'translates :blank error message' do
      contact.phone = nil
      contact.validate
      expect(contact.errors.generate_message(:phone, :blank)).to eq('Required parameter missing - phone')
    end

    it 'translates :invalid error message' do
      contact.phone = nil
      contact.validate
      expect(contact.errors.generate_message(:phone, :invalid)).to eq('Phone nr is invalid')
    end
  end
end
