require 'rails_helper'

describe Contact do
  before { create_disclosure_settings }
  it { should have_one(:address) }

  context 'with invalid attribute' do
    before(:each) { @contact = Fabricate(:contact) }

    it 'phone should return false' do
      @contact.phone = '32341'
      expect(@contact.valid?).to be false
    end

    it 'ident should return false' do
      @contact.ident = '123abc'
      expect(@contact.valid?).to be false
    end

    it 'should return missing parameter error messages' do
      @contact = Contact.new
      expect(@contact.valid?).to eq false

      expect(@contact.errors.messages).to match_array({
         name: ['Required parameter missing - name'],
         phone: ['Required parameter missing - phone', 'Phone nr is invalid'],
         email: ['Required parameter missing - email', 'Email is invalid'],
         ident: ['Required parameter missing - ident'],
         address: ['is missing'],
         registrar: ['is missing']
      })
    end
  end

  context 'with valid attributes' do
    before(:each) { @contact = Fabricate(:contact, disclosure: nil) }

    it 'should return true' do
      expect(@contact.valid?).to be true
    end

    it 'should have default disclosure'  do
      expect(@contact.disclosure.name).to be true
      expect(@contact.disclosure.org_name).to be true
      expect(@contact.disclosure.email).to be true
      expect(@contact.disclosure.phone).to be false
      expect(@contact.disclosure.fax).to be false
      expect(@contact.disclosure.address).to be false
    end

    it 'should have custom disclosure' do
      @contact = Fabricate(:contact, disclosure: Fabricate(:contact_disclosure))
      expect(@contact.disclosure.name).to be true
      expect(@contact.disclosure.org_name).to be true
      expect(@contact.disclosure.email).to be true
      expect(@contact.disclosure.phone).to be true
      expect(@contact.disclosure.fax).to be true
      expect(@contact.disclosure.address).to be true
    end
  end

  context 'with callbacks' do
    before(:each) { @contact = Fabricate.build(:contact, code: '123asd', auth_info: 'qwe321') }

    context 'after create' do
      it 'should generate code' do
        expect(@contact.code).to eq('123asd')
        @contact.save!
        expect(@contact.code).to_not eq('123asd')
      end

      it 'should generate password' do
        expect(@contact.auth_info).to eq('qwe321')
        @contact.save!
        expect(@contact.auth_info).to_not eq('qwe321')
      end
    end

    context 'after update' do
      before(:each) do
        @contact.save!
        @code = @contact.code
        @auth_info = @contact.auth_info
      end

      it 'should not generate new code' do
        @contact.update_attributes(name: 'qevciherot23')
        expect(@contact.code).to eq(@code)
      end

      it 'should not generate new auth_info' do
        @contact.update_attributes(name: 'fvrsgbqevciherot23')
        expect(@contact.auth_info).to eq(@auth_info)
      end
    end

  end
end

describe Contact, '#relations_with_domain?' do
  context 'with no relation' do
    before(:each) { Fabricate(:contact) }
    it 'should return false' do
      expect(Contact.first.relations_with_domain?).to be false
    end
  end

  context 'with relation' do
    before(:each) do
      create_settings
      Fabricate(:domain)
    end

    it 'should return true' do
      expect(Contact.first.relations_with_domain?).to be true
    end
  end
end

describe Contact, '#cr_id' do
  before(:each) { Fabricate(:contact, code: 'asd12', created_by: Fabricate(:epp_user)) }

  it 'should return username of creator' do
    expect(Contact.first.cr_id).to eq('gitlab')
  end

  it 'should return nil when no creator' do
    expect(Contact.new.cr_id).to be nil
  end
end

describe Contact, '#up_id' do
  before(:each) do
    # Fabricate(:contact, code: 'asd12',
    # created_by: Fabricate(:epp_user),
    # updated_by: Fabricate(:epp_user), registrar: zone)
    @epp_user = Fabricate(:epp_user)
    @contact = Fabricate.build(:contact, code: 'asd12', created_by: @epp_user, updated_by: @epp_user)
  end

  it 'should return username of updater' do
    expect(@contact.up_id).to eq('gitlab')
  end

  it 'should return nil when no updater' do
    expect(Contact.new.up_id).to be nil
  end
end

describe Contact, '.extract_params' do
  it 'returns params hash'do
    ph = { id: '123123', email: 'jdoe@example.com', authInfo: { pw: 'asde' },
           postalInfo: { name: 'fred', addr: { cc: 'EE' } }  }
    expect(Contact.extract_attributes(ph)).to eq({
      name: 'fred',
      email: 'jdoe@example.com'
    })
  end
end

describe Contact, '.check_availability' do

  before(:each) do
    Fabricate(:contact, code: 'asd12')
    Fabricate(:contact, code: 'asd13')
  end

  it 'should return array if argument is string' do
    response = Contact.check_availability('asd12')
    expect(response.class).to be Array
    expect(response.length).to eq(1)
  end

  it 'should return in_use and available codes' do
    code = Contact.first.code
    code_ = Contact.last.code

    response = Contact.check_availability([code, code_, 'asd14'])
    expect(response.class).to be Array
    expect(response.length).to eq(3)

    expect(response[0][:avail]).to eq(0)
    expect(response[0][:code]).to eq(code)

    expect(response[1][:avail]).to eq(0)
    expect(response[1][:code]).to eq(code_)

    expect(response[2][:avail]).to eq(1)
    expect(response[2][:code]).to eq('asd14')
  end
end
