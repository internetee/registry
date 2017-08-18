require 'rails_helper'
require 'lib/validators/e164'

RSpec.describe Contact do
  let(:contact) { described_class.new }

  describe 'phone', db: false do
    it_behaves_like 'e164' do
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
  end
end
