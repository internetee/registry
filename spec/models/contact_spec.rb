require 'rails_helper'

RSpec.describe Contact do
  before :example do
    create(:zone, origin: 'ee')
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
      @contact = create(:contact)
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

    it 'should not overwrite code' do
      old_code = @contact.code
      @contact.code = 'CID:REG1:should-not-overwrite-old-code-12345'
      @contact.save.should == true
      @contact.code.should == old_code
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
      contact = create(:contact)
      contact.statuses = [Contact::SERVER_UPDATE_PROHIBITED]
      contact.statuses.should == [Contact::SERVER_UPDATE_PROHIBITED] # temp test
      contact.save
      contact.statuses.should == [Contact::SERVER_UPDATE_PROHIBITED]
    end

    it 'should have code' do
      registrar = create(:registrar, code: 'registrarcode')

      contact = build(:contact, registrar: registrar, code: 'contactcode')
      contact.generate_code
      contact.save!

      expect(contact.code).to eq('REGISTRARCODE:CONTACTCODE')
    end

    it 'should save status notes' do
      contact = create(:contact)
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
      contact = create(:contact)
      contact.update_column(:ident_updated_at, nil)

      Contact.find(contact.id).ident_updated_at.should == nil
    end

    context 'as birthday' do
      before do
        @domain = create(:domain)
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

    context 'with callbacks' do
      context 'after create' do
        it 'should not allow to use same code' do
          registrar = create(:registrar, code: 'FIXED')

          create(:contact,
                           registrar: registrar,
                           code: 'FIXED:new-code')
          @contact = build(:contact,
                                     registrar: registrar,
                                     code: 'FIXED:new-code')

          @contact.validate

          expect(@contact.errors).to have_key(:code)
        end

        it 'should allow supported code format' do
          @contact = build(:contact, code: 'CID:REG1:12345', registrar: create(:registrar, code: 'FIXED'))
          @contact.valid?
          @contact.errors.full_messages.should == []
        end

        it 'should not allow unsupported characters in code' do
          @contact = build(:contact, code: 'unsupported!ÄÖÜ~?', registrar: create(:registrar, code: 'FIXED'))
          @contact.valid?
          @contact.errors.full_messages.should == ['Code is invalid']
        end

        it 'should generate code if empty code is given' do
          @contact = build(:contact, code: '')
          @contact.generate_code
          @contact.save!
          @contact.code.should_not == ''
        end

        it 'should not ignore empty spaces as code and generate new one' do
          @contact = build(:contact, code: '    ', registrar: create(:registrar, code: 'FIXED'))
          @contact.generate_code
          @contact.valid?.should == true
          @contact.code.should =~ /FIXED:..../
        end
      end
    end
  end
end

describe Contact, '.destroy_orphans' do
  before do
    create(:zone, origin: 'ee')
    @contact_1 = create(:contact, code: 'asd12')
    @contact_2 = create(:contact, code: 'asd13')
  end

  it 'destroys orphans' do
    Contact.find_orphans.count.should == 2
    Contact.destroy_orphans
    Contact.find_orphans.count.should == 0
  end

  it 'should find one orphan' do
    create(:domain, registrant: Registrant.find(@contact_1.id))
    Contact.find_orphans.count.should == 1
    Contact.find_orphans.last.should == @contact_2
  end

  it 'should find no orphans' do
    create(:domain, registrant: Registrant.find(@contact_1.id), admin_contacts: [@contact_2])
    cc = Contact.count
    Contact.find_orphans.count.should == 0
    Contact.destroy_orphans
    Contact.count.should == cc
  end
end

RSpec.describe Contact do
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

  describe 'registrar validation', db: false do
    let(:contact) { described_class.new }

    it 'rejects absent' do
      contact.registrar = nil
      contact.validate
      expect(contact.errors).to have_key(:registrar)
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

  describe 'country code validation', db: false do
    let(:contact) { described_class.new(country_code: 'test') }

    it 'rejects invalid' do
      contact.country_code = 'invalid'
      contact.validate
      expect(contact.errors).to have_key(:country_code)
    end
  end

  describe 'identifier validation', db: false do
    let(:contact) { described_class.new }

    it 'rejects invalid' do
      ident = Contact::Ident.new
      ident.validate
      contact.identifier = ident
      contact.validate

      expect(contact.errors).to be_added(:identifier, :invalid)
    end

    it 'accepts valid' do
      ident = Contact::Ident.new(code: 'test', type: 'priv', country_code: 'US')
      ident.validate
      contact.identifier = ident
      contact.validate

      expect(contact.errors).to_not be_added(:identifier, :invalid)
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
      let(:contact) { build_stubbed(:contact_legal_entity, ident: '1234') }

      specify { expect(reg_no).to eq('1234') }
    end

    context 'when contact is private entity' do
      let(:contact) { build_stubbed(:contact_private_entity, ident: '1234') }

      specify { expect(reg_no).to be_nil }
    end
  end

  describe '#id_code' do
    context 'when contact is private entity' do
      let(:contact) { build_stubbed(:contact_private_entity, ident: '1234') }

      specify { expect(contact.id_code).to eq('1234') }
    end

    context 'when contact is legal entity' do
      let(:contact) { build_stubbed(:contact_legal_entity, ident: '1234') }

      specify { expect(contact.id_code).to be_nil }
    end
  end

  describe '#ident_country' do
    let(:contact) { described_class.new(ident_country_code: 'US') }

    it 'returns ident country' do
      expect(contact.ident_country).to eq(Country.new('US'))
    end
  end

  describe '#used?' do
    context 'when used as registrant' do
      let(:registrant) { create(:registrant) }

      before :example do
        create(:domain, registrant: registrant)
        registrant.reload
      end

      specify { expect(registrant).to be_used }
    end

    context 'when used as contact' do
      let(:contact) { create(:contact) }

      before :example do
        domain = create(:domain)
        domain.admin_domain_contacts << create(:admin_domain_contact, contact: contact)
        contact.reload
      end

      specify { expect(contact).to be_used }
    end

    context 'when not used' do
      let(:contact) { create(:contact) }
      specify { expect(contact).to_not be_used }
    end
  end

  describe '#domain_names_with_roles' do
    let(:contact) { create(:registrant) }
    subject(:domain_names) { contact.domain_names_with_roles }

    it 'returns associated domains with roles' do
      domain = create(:domain, registrant: contact, name: 'test.com')
      domain.admin_domain_contacts << create(:admin_domain_contact, contact: contact)
      domain.tech_domain_contacts << create(:tech_domain_contact, contact: contact)

      contact.reload

      expect(domain_names).to eq({ 'test.com' => %i[registrant admin_domain_contact tech_domain_contact].to_set })
    end

    it 'returns unique roles' do
      domain = create(:domain, name: 'test.com')
      2.times { domain.admin_domain_contacts << create(:admin_domain_contact, contact: contact) }

      contact.reload

      expect(domain_names).to eq({ 'test.com' => %i[admin_domain_contact].to_set })
    end
  end

  it 'normalizes ident country code', db: false do
    contact = described_class.new

    contact.ident_country_code = 'ee'
    contact.validate

    expect(contact.ident_country_code).to eq('EE')
  end
end
