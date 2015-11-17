require 'rails_helper'

describe ContactMailer do
  before :all do
    Fabricate(:zonefile_setting, origin: 'ee')
  end

  describe 'email changed notification when delivery turned off' do
    before :all do
      @contact = Fabricate(:contact, email: 'test@example.ee')
      @mail = ContactMailer.email_updated('test@example.com', @contact.id)
    end

    it 'should not render email subject' do
      @mail.subject.should == nil
    end

    it 'should not have sender email' do
      @mail.from.should == nil
    end

    it 'should not have reveiver email' do
      @mail.to.should == nil
    end

    it 'should not render body' do
      @mail.body.should == ''
    end
  end

  describe 'email changed notification' do
    before :all do
      @domain = Fabricate(:domain)
      @contact = @domain.registrant
      @contact.reload # until figured out why registrant_domains not loaded
      @contact.deliver_emails = true
      @mail = ContactMailer.email_updated('info@example.org', @contact.id)
    end

    it 'should render email subject' do
      @mail.subject.should =~ /Teie domeenide kontakt epostiaadress on muutunud/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send to info email' do
      @mail.to.should == ['info@example.org']
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /Kontaktandmed:/
    end
  end

  describe 'email with pynicode' do
    before :all do
      @domain = Fabricate(:domain)
      @contact = @domain.registrant
      @contact.reload # until figured out why registrant_domains not loaded
      @contact.deliver_emails = true
      @mail = ContactMailer.email_updated('info@ääöü.org', @contact.id)
    end

    it 'should render email subject' do
      @mail.subject.should =~ /Teie domeenide kontakt epostiaadress on muutunud/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send to info email' do
      @mail.to.should == ['info@xn--4caa8cya.org']
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /Kontaktandmed:/
    end
  end
end
