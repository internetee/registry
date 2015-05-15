require 'rails_helper'

describe DomainMailer do
  describe 'registrant changed notification when delivery turned off' do
    before :all do 
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @domain = Fabricate(:domain, registrant: @registrant)
      @mail = DomainMailer.registrant_updated(@domain)
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
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @new_registrant = Fabricate(:registrant, email: 'test@example.org')
      @domain = Fabricate(:domain, registrant: @registrant)
      @domain.deliver_emails = true
      @domain.registrant_verification_token = '123'
      @domain.registrant = @new_registrant
      @mail = DomainMailer.registrant_updated(@domain)
    end

    it 'should render email subject' do
      @mail.subject.should =~ /Kinnitustaotlus domeeni/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send confirm email to old registrant email' do
      @mail.to.should == ["test@example.com"]
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /Registrisse laekus taotlus domeeni/
    end

    it 'should render verification url' do
      @mail.body.encoded.should =~ /registrant\/domain_update_confirms/
    end
  end
end
