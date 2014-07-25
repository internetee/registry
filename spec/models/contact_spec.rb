require "rails_helper"

describe Contact do
  it { should have_many(:addresses) }

  context 'with invalid attribute' do
    before(:each) { @contact = Fabricate(:contact) }

    it 'phone should return false' do
      @contact.phone = "32341"
      expect(@contact.valid?).to be false
    end

    it 'ident should return false' do
      @contact.ident = "123abc"
      expect(@contact.valid?).to be false
    end
  end

  context 'with valid attributes' do
    before(:each) { @contact = Fabricate(:contact) }

    it 'should return true' do
      expect(@contact.valid?).to be true 
    end
  end
end
