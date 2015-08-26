require 'rails_helper'

describe ContactMailer do
  describe 'email changed notification when delivery turned off' do
    before :all do
      @contact = Fabricate(:contact, email: 'test@example.ee')
      @mail = ContactMailer.email_updated('test@example.com', @contact)
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
      Fabricate(:zonefile_setting, origin: 'ee')
      @domain = Fabricate(:domain)
      @contact = @domain.registrant
      @contact.reload # until figured out why registrant_domains not loaded
      @contact.deliver_emails = true
      @mail = ContactMailer.email_updated('info@example.org', @contact)
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
end
