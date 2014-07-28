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

describe Contact, '.check_availability' do

  before(:each) {
    Fabricate(:contact, code: "asd12")
    Fabricate(:contact, code: "asd13")
  }

  it 'should return array if argument is string' do
    response = Contact.check_availability("asd12")
    expect(response.class).to be Array
    expect(response.length).to eq(1)
  end

  it 'should return in_use and available codes' do
    response = Contact.check_availability(["asd12","asd13","asd14"])
    expect(response.class).to be Array
    expect(response.length).to eq(3)

    expect(response[0][:avail]).to eq(0)
    expect(response[0][:code]).to eq("asd12")

    expect(response[1][:avail]).to eq(0)
    expect(response[1][:code]).to eq("asd13")

    expect(response[2][:avail]).to eq(1)
    expect(response[2][:code]).to eq("asd14")
  end
end

