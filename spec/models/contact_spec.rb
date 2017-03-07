require 'rails_helper'

RSpec.describe Contact do
  before :example do
    Fabricate(:zonefile_setting, origin: 'ee')
  end

  context 'about class' do
    it 'should have versioning enabled?' do
      Contact.paper_trail_enabled_for_model?.should == true
    end

    it 'should have custom log prexied table name for versions table' do
      ContactVersion.table_name.should == 'log_contacts'
    end
  end

  context 'with invalid attribute' do
    before :example do
      @contact = Contact.new
    end

    it 'should not have creator' do
      @contact.creator.should == nil
    end

    it 'should not have updater' do
      @contact.updator.should == nil
    end

    it 'should require country code when org' do
      @contact.ident_type = 'org'
      @contact.valid?
      @contact.errors[:ident_country_code].should == ['is missing']
    end

    it 'should require country code when priv' do
      @contact.ident_type = 'priv'
      @contact.valid?
      @contact.errors[:ident_country_code].should == ['is missing']
    end

    it 'should validate correct country code' do
      @contact.ident = 1
      @contact.ident_type = 'org'
      @contact.ident_country_code = 'EE'
      @contact.valid?

      @contact.errors[:ident_country_code].should == []
    end

    it 'should require valid country code' do
      @contact.ident = '123'
      @contact.ident_type = 'org'
      @contact.ident_country_code = 'INVALID'
      @contact.valid?

      expect(@contact.errors).to have_key(:ident)
    end

    it 'should convert to alpha2 country code' do
      @contact.ident = 1
      @contact.ident_type = 'org'
      @contact.ident_country_code = 'ee'
      @contact.validate

      @contact.ident_country_code.should == 'EE'
    end

    it 'should not have any versions' do
      @contact.versions.should == []
    end

    it 'should not accept long code' do
      @contact.code = 'verylongcode' * 100
      @contact.valid?
      @contact.errors[:code].should == ['Contact code is too long, max 100 characters']
    end

    it 'should not allow double status' do
      contact = described_class.new(statuses: %w(ok ok))

      contact.validate

      expect(contact.statuses).to eq(%w(ok))
    end

    it 'should have no related domain descriptions' do
      @contact.related_domain_descriptions.should == {}
    end

    it 'should fully validate email syntax for new records' do
      @contact.email = 'not@correct'
      @contact.valid?
      @contact.errors[:email].should == ['Email is invalid']
    end

    it 'should have ident updated because the logic itself is dedicated for legacy contacts ' do
      @contact.ident_updated_at.should_not == nil
    end
  end

  context 'with valid attributes' do
    before :example do
      @contact = Fabricate(:contact)
    end

    it 'should have one version' do
      with_versioning do
        @contact.versions.reload.should == []
        @contact.name = 'New name'
        @contact.save
        @contact.errors.full_messages.should match_array([])
        @contact.versions.size.should == 1
      end
    end

    it 'should not have relation with domains' do
      @contact.domains_present?.should == false
    end

    it 'org should be valid' do
      contact = Fabricate.build(:contact, ident_type: 'org', ident: '1' * 8)

      contact.validate

      contact.errors.full_messages.should match_array([])
    end

    it 'should not overwrite code' do
      old_code = @contact.code
      @contact.code = 'CID:REG1:should-not-overwrite-old-code-12345'
      @contact.save.should == true
      @contact.code.should == old_code
    end

    it 'should have static password' do
      @contact.auth_info.should == 'password'
    end

    it 'should have ok status by default' do
      @contact.statuses.should == %w(ok)
    end

    it 'should not remove ok status after save' do
      @contact.statuses.should == %w(ok)
      @contact.save
      @contact.statuses.should == %w(ok)
    end

    it 'should remove ok status when other non linked status present' do
      contact = Fabricate(:contact)
      contact.statuses = [Contact::SERVER_UPDATE_PROHIBITED]
      contact.statuses.should == [Contact::SERVER_UPDATE_PROHIBITED] # temp test
      contact.save
      contact.statuses.should == [Contact::SERVER_UPDATE_PROHIBITED]
    end

    it 'should have code' do
      registrar = Fabricate.create(:registrar, code: 'registrarcode')

      contact = Fabricate.build(:contact, registrar: registrar, code: 'contactcode')
      contact.generate_code
      contact.save!

      expect(contact.code).to eq('REGISTRARCODE:CONTACTCODE')
    end

    it 'should save status notes' do
      contact = Fabricate(:contact)
      contact.statuses = ['serverDeleteProhibited', 'serverUpdateProhibited']
      contact.status_notes_array = [nil, 'update manually turned off']
      contact.status_notes['serverDeleteProhibited'].should == nil
      contact.status_notes['serverUpdateProhibited'].should == 'update manually turned off'
      contact.status_notes['someotherstatus'].should == nil
    end

    it 'should have ident already updated because the logic itself is only for legacy contacts' do
      @contact.ident_updated_at.should_not == nil
    end

    it 'should have not update ident updated at when initializing old contact' do
      # creating a legacy contact
      contact = Fabricate(:contact)
      contact.update_column(:ident_updated_at, nil)

      Contact.find(contact.id).ident_updated_at.should == nil
    end

    context 'as birthday' do
      before do
        @domain = Fabricate(:domain)
      end

      it 'should have related domain descriptions hash' do
        contact = @domain.registrant
        contact.reload # somehow it registrant_domains are empty?
        contact.related_domain_descriptions.should == { "#{@domain.name}" => [:registrant] }
      end

      it 'should have related domain descriptions hash when find directly' do
        contact = @domain.registrant
        Contact.find(contact.id).related_domain_descriptions.should == { "#{@domain.name}" => [:registrant] }
      end

      it 'should have related domain descriptions hash' do
        contact = @domain.contacts.first
        contact.related_domain_descriptions.should == { "#{@domain.name}" => [:admin] }
      end

      it 'should fully validate email syntax for old records' do
        old = @contact.email
        @contact.email = 'legacy@support-not-correct'
        @contact.valid?
        @contact.errors[:email].should == ['Email is invalid']
        @contact.email = old
      end
    end

    context 'as birthday' do
      before :example do
        @contact.ident_type = 'birthday'
      end

      it 'birthday should be valid' do
        valid = ['2012-12-11', '1990-02-16']
        valid.each do |date|
          @contact.ident = date
          @contact.valid?
          @contact.errors.full_messages.should match_array([])
        end
      end

      it 'birthday should be invalid' do
        invalid = ['123' '12/12/2012', 'aaaa', '12/12/12', '02-11-1999']
        invalid.each do |date|
          @contact.ident = date
          @contact.valid?
          @contact.errors.full_messages.should ==
            ["Ident Ident not in valid birthady format, should be YYYY-MM-DD"]
        end
      end
    end

    context 'with callbacks' do
      before :example do
        # Ensure callbacks are not taken out from other specs
        Contact.set_callback(:create, :before, :generate_auth_info)
      end

      context 'after create' do
        it 'should not allow to use same code' do
          registrar = Fabricate.create(:registrar, code: 'FIXED')

          Fabricate.create(:contact,
                           registrar: registrar,
                           code: 'FIXED:new-code',
                           auth_info: 'qwe321')
          @contact = Fabricate.build(:contact,
                                     registrar: registrar,
                                     code: 'FIXED:new-code',
                                     auth_info: 'qwe321')

          @contact.validate

          expect(@contact.errors).to have_key(:code)
        end

        it 'should generate a new password' do
          @contact = Fabricate.build(:contact, code: '123asd', auth_info: nil)
          @contact.auth_info.should == nil
          @contact.save.should == true
          @contact.auth_info.should_not be_nil
        end

        it 'should allow supported code format' do
          @contact = Fabricate.build(:contact, code: 'CID:REG1:12345', registrar: Fabricate(:registrar, code: 'FIXED'))
          @contact.valid?
          @contact.errors.full_messages.should == []
        end

        it 'should not allow unsupported characters in code' do
          @contact = Fabricate.build(:contact, code: 'unsupported!ÄÖÜ~?', registrar: Fabricate(:registrar, code: 'FIXED'))
          @contact.valid?
          @contact.errors.full_messages.should == ['Code is invalid']
        end

        it 'should generate code if empty code is given' do
          @contact = Fabricate.build(:contact, code: '')
          @contact.generate_code
          @contact.save!
          @contact.code.should_not == ''
        end

        it 'should not ignore empty spaces as code and generate new one' do
          @contact = Fabricate.build(:contact, code: '    ', registrar: Fabricate(:registrar, code: 'FIXED'))
          @contact.generate_code
          @contact.valid?.should == true
          @contact.code.should =~ /FIXED:..../
        end
      end

      context 'after update' do
        before :example do
          @contact = Fabricate.build(:contact,
                                     registrar: Fabricate(:registrar, code: 'FIXED'),
                                     code: '123asd',
                                     auth_info: 'qwe321')
          @contact.generate_code
          @contact.save
          @contact.code.should == 'FIXED:123ASD'
          @auth_info = @contact.auth_info
        end

        it 'should not generate new code' do
          @contact.update_attributes(name: 'qevciherot23')
          @contact.code.should == 'FIXED:123ASD'
        end

        it 'should not generate new auth_info' do
          @contact.update_attributes(name: 'fvrsgbqevciherot23')
          @contact.auth_info.should == @auth_info
        end
      end
    end
  end
end

describe Contact, '.destroy_orphans' do
  before do
    Fabricate(:zonefile_setting, origin: 'ee')
    @contact_1 = Fabricate(:contact, code: 'asd12')
    @contact_2 = Fabricate(:contact, code: 'asd13')
  end

  it 'destroys orphans' do
    Contact.find_orphans.count.should == 2
    Contact.destroy_orphans
    Contact.find_orphans.count.should == 0
  end

  it 'should find one orphan' do
    Fabricate(:domain, registrant: Registrant.find(@contact_1.id))
    Contact.find_orphans.count.should == 1
    Contact.find_orphans.last.should == @contact_2
  end

  it 'should find no orphans' do
    Fabricate(:domain, registrant: Registrant.find(@contact_1.id), admin_contacts: [@contact_2])
    cc = Contact.count
    Contact.find_orphans.count.should == 0
    Contact.destroy_orphans
    Contact.count.should == cc
  end
end

RSpec.describe Contact, db: false do
  it { is_expected.to alias_attribute(:kind, :ident_type) }

  describe '::names' do
    before :example do
      expect(described_class).to receive(:pluck).with(:name).and_return('names')
    end

    it 'returns names' do
      expect(described_class.names).to eq('names')
    end
  end

  describe '::emails' do
    before :example do
      expect(described_class).to receive(:pluck).with(:email).and_return('emails')
    end

    it 'returns emails' do
      expect(described_class.emails).to eq('emails')
    end
  end

  describe '::address_processing?' do
    before do
      Setting.address_processing = 'test'
    end

    it 'returns setting value' do
      expect(described_class.address_processing?).to eq('test')
    end
  end

  describe '::address_attribute_names', db: false do
    it 'returns address attributes' do
      attributes = %w(
        city
        street
        zip
        country_code
        state
      )
      expect(described_class.address_attribute_names).to eq(attributes)
    end
  end

  describe 'address validation', db: false do
    let(:contact) { described_class.new }
    subject(:errors) { contact.errors }

    required_attributes = %i(street city zip country_code)

    context 'when address processing is enabled' do
      before do
        allow(described_class).to receive(:address_processing?).and_return(true)
      end

      required_attributes.each do |attr_name|
        it "rejects absent #{attr_name}" do
          contact.send("#{attr_name}=", nil)
          contact.validate
          expect(errors).to have_key(attr_name)
        end
      end
    end

    context 'when address processing is disabled' do
      before do
        allow(described_class).to receive(:address_processing?).and_return(false)
      end

      required_attributes.each do |attr_name|
        it "accepts absent #{attr_name}" do
          contact.send("#{attr_name}=", nil)
          contact.validate
          expect(errors).to_not have_key(attr_name)
        end
      end
    end
  end

  describe 'country code validation' do
    let(:contact) { described_class.new(country_code: 'test') }

    it 'rejects invalid' do
      contact.country_code = 'invalid'
      contact.validate
      expect(contact.errors).to have_key(:country_code)
    end
  end

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

  describe '#remove_address' do
    let(:contact) { described_class.new(city: 'test',
                                        street: 'test',
                                        zip: 'test',
                                        country_code: 'test',
                                        state: 'test')
    }
    subject(:address_removed) { contact.attributes.slice(*described_class.address_attribute_names).compact.empty? }

    it 'removes address attributes' do
      contact.remove_address
      expect(address_removed).to be_truthy
    end
  end

  describe '#reg_no' do
    subject(:reg_no) { contact.reg_no }

    context 'when contact is legal entity' do
      let(:contact) { FactoryGirl.build_stubbed(:contact_legal_entity, ident: '1234') }

      specify { expect(reg_no).to eq('1234') }
    end

    context 'when contact is private entity' do
      let(:contact) { FactoryGirl.build_stubbed(:contact_private_entity, ident: '1234') }

      specify { expect(reg_no).to be_nil }
    end
  end

  describe '#id_code' do
    context 'when contact is private entity' do
      let(:contact) { FactoryGirl.build_stubbed(:contact_private_entity, ident: '1234') }

      specify { expect(contact.id_code).to eq('1234') }
    end

    context 'when contact is legal entity' do
      let(:contact) { FactoryGirl.build_stubbed(:contact_legal_entity, ident: '1234') }

      specify { expect(contact.id_code).to be_nil }
    end
  end
end
