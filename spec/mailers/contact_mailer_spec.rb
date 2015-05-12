require 'rails_helper'

describe ContactMailer do
  describe 'email changed notification when delivery turned off' do
    before :all do 
      @contact = Fabricate(:contact, email: 'test@example.ee')
      @contact.email = 'test@example.com' # new email
      @mail = ContactMailer.email_updated(@contact)
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
      @contact = Fabricate(:contact, email: 'test@example.ee')
      @contact.deliver_emails = true
      @contact.email = 'test@example.com' # new email
      @mail = ContactMailer.email_updated(@contact)
    end

    it 'should render email subject' do
      @mail.subject.should =~ /Teie domeenide kontakt epostiaadress on muutunud/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should have both old and new receiver email' do
      @mail.to.should == ['test@example.com', 'test@example.ee']
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /Kontaktandmed:/
    end
  end
end
