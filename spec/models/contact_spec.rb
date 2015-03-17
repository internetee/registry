require 'rails_helper'

describe Contact do
  before :all do
    create_disclosure_settings
    @api_user = Fabricate(:api_user)
  end

  it { should have_one(:address) }

  context 'about class' do
    it 'should have versioning enabled?' do
      Contact.paper_trail_enabled_for_model?.should == true
    end

    it 'should have custom log prexied table name for versions table' do
      ContactVersion.table_name.should == 'log_contacts'
    end
  end

  context 'with invalid attribute' do
    before :all do
      @contact = Contact.new
    end

    it 'should not be valid' do
      @contact.valid?
      @contact.errors.full_messages.should match_array([
        "Name Required parameter missing - name",
        "Phone Required parameter missing - phone",
        "Phone Phone nr is invalid",
        "Email Required parameter missing - email",
        "Email Email is invalid",
        "Ident Required parameter missing - ident",
        "Address is missing",
        "Registrar is missing",
        "Ident type is missing"
      ])
    end

    it 'should not have creator' do
      @contact.creator.should == nil
    end

    it 'should not have updater' do
      @contact.updator.should == nil
    end

    it 'phone should return false' do
      @contact.phone = '32341'
      @contact.valid?
      @contact.errors[:phone].should == ["Phone nr is invalid"]
    end

    it 'should require country code when bic' do
      @contact.ident_type = 'bic'
      @contact.valid?
      @contact.errors[:ident_country_code].should == ['is missing']
    end

    it 'should require country code when priv' do
      @contact.ident_type = 'priv'
      @contact.valid?
      @contact.errors[:ident_country_code].should == ['is missing']
    end

    it 'should validate correct country code' do
      @contact.ident_type = 'bic'
      @contact.ident_country_code = 'EE'
      @contact.valid?

      @contact.errors[:ident_country_code].should == []
    end

    it 'should require valid country code' do
      @contact.ident_type = 'bic'
      @contact.ident_country_code = 'INVALID'
      @contact.valid?

      @contact.errors[:ident_country_code].should == ['is not following ISO_3166-1 alpha 2 format']
    end

    it 'should convert to alpha2 country code' do
      @contact.ident_type = 'bic'
      @contact.ident_country_code = 'ee'
      @contact.valid?

      @contact.ident_country_code.should == 'EE'
    end

    it 'should not have any versions' do
      @contact.versions.should == []
    end

    it 'should not accept long code' do
      @contact.code = 'verylongcode' * 100
      @contact.valid?
      @contact.errors[:code].should == ['is too long (maximum is 100 characters)']
    end
  end

  context 'with valid attributes' do
    before :all do
      @contact = Fabricate(:contact, disclosure: nil)
    end

    it 'should be valid' do
      @contact.valid?
      @contact.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @contact = Fabricate(:contact)
      @contact.valid?
      @contact.errors.full_messages.should match_array([])
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

    it 'should not have relation' do
      @contact.relations_with_domain?.should == false
    end

    it 'bic should be valid' do
      @contact.ident_type = 'bic'
      @contact.ident = '1234'
      @contact.valid?
      @contact.errors.full_messages.should match_array([])
    end

    it 'should not accept new custom code' do
      old_code = @contact.code
      @contact.code = 'CID:REG1:12345'
      @contact.save.should == true
      @contact.code.should == old_code
    end

    it 'should have static password' do
      @contact.auth_info.should == 'password'
    end

    it 'should have ok status by default' do
      @contact.statuses.size.should == 1
      @contact.statuses.first.value.should == 'ok'
    end

    it 'should have linked status when domain' do
      @domain_contact = Fabricate(:domain_contact, contact_type: 'admin', contact_id: @contact.id)
      @domain = Fabricate(:domain, domain_contacts: [@domain_contact])
      contact = @domain.contacts.first
      contact.save

      contact.statuses.map(&:value).should == %w(ok linked)
    end

    it 'should not have linked status when no domain' do
      @domain_contact = Fabricate(:domain_contact, contact_type: 'admin', contact_id: @contact.id)
      @domain = Fabricate(:domain, domain_contacts: [@domain_contact])
      contact = @domain.contacts.first
      contact.save

      contact.statuses.map(&:value).should == %w(ok linked)

      contact.domains.destroy_all
      contact.save
      contact.statuses.map(&:value).should == %w(ok)
    end

    context 'as birthday' do
      before :all do
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

    it 'should have empty disclosure'  do
      @contact.disclosure.name.should     == nil
      @contact.disclosure.org_name.should == nil
      @contact.disclosure.email.should    == nil
      @contact.disclosure.phone.should    == nil
      @contact.disclosure.fax.should      == nil
      @contact.disclosure.address.should  == nil
    end

    it 'should have custom disclosure' do
      @contact = Fabricate(:contact, disclosure: Fabricate(:contact_disclosure))
      @contact.disclosure.name.should     == true
      @contact.disclosure.org_name.should == true
      @contact.disclosure.email.should    == true
      @contact.disclosure.phone.should    == true
      @contact.disclosure.fax.should      == true
      @contact.disclosure.address.should  == true
    end

    context 'with callbacks' do
      before :all do
        # Ensure callbacks are not taken out from other specs
        Contact.set_callback(:create, :before, :generate_code)
        Contact.set_callback(:create, :before, :generate_auth_info)
      end

      context 'after create' do
        it 'should not generate a new code when code is present' do
          @contact = Fabricate.build(:contact, code: '123asd', auth_info: 'qwe321')
          @contact.code.should == '123asd'
          @contact.save.should == true
          @contact.code.should == '123asd'
        end

        it 'should generate a new password' do
          @contact = Fabricate.build(:contact, code: '123asd', auth_info: 'qwe321')
          @contact.auth_info.should == 'qwe321'
          @contact.save.should == true
          @contact.auth_info.should_not == 'qwe321'
        end

        it 'should not allow same code' do
          @double_contact = Fabricate.build(:contact, code: @contact.code)
          @double_contact.valid?
          @double_contact.errors.full_messages.should == ["Code Contact id already exists"]
        end

        it 'should allow supported code format' do
          @contact = Fabricate.build(:contact, code: 'CID:REG1:12345')
          @contact.valid?
          @contact.errors.full_messages.should == []
        end

        it 'should not allow unsupported characters in code' do
          @contact = Fabricate.build(:contact, code: 'unsupported!ÄÖÜ~?')
          @contact.valid?
          @contact.errors.full_messages.should == ['Code is invalid']
        end

        it 'should generate code if empty code is given' do
          @contact = Fabricate(:contact, code: '')
          @contact.code.should_not == ''
        end

        it 'should not allow empty spaces as code' do
          @contact = Fabricate.build(:contact, code: '    ')
          @contact.valid?
          @contact.errors.full_messages.should == ['Code is invalid']
        end
      end

      context 'after update' do
        before :all do
          @contact = Fabricate.build(:contact, code: '123asd', auth_info: 'qwe321')
          @contact.save
          @contact.code.should == '123asd'
          @auth_info = @contact.auth_info
        end

        it 'should not generate new code' do
          @contact.update_attributes(name: 'qevciherot23')
          @contact.code.should == '123asd'
        end

        it 'should not generate new auth_info' do
          @contact.update_attributes(name: 'fvrsgbqevciherot23')
          @contact.auth_info.should == @auth_info
        end
      end
    end
  end
end

describe Contact, '.check_availability' do
  before do
    Fabricate(:contact, code: 'asd12')
    Fabricate(:contact, code: 'asd13')
  end

  it 'should return array if argument is string' do
    response = Contact.check_availability('asd12')
    response.class.should == Array
    response.length.should == 1
  end

  it 'should return in_use and available codes' do
    code = Contact.first.code
    code_ = Contact.last.code

    response = Contact.check_availability([code, code_, 'asd14'])
    response.class.should == Array
    response.length.should == 3

    response[0][:avail].should == 0
    response[0][:code].should == code

    response[1][:avail].should == 0
    response[1][:code].should == code_

    response[2][:avail].should == 1
    response[2][:code].should == 'asd14'
  end
end
