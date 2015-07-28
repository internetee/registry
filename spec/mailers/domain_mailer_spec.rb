require 'rails_helper'

describe DomainMailer do
  describe 'registrant change request for old registrant when delivery turned off' do
    before :all do 
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @domain = Fabricate(:domain, registrant: @registrant)
      @mail = DomainMailer.pending_update_old_registrant_request(@domain)
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

  describe 'registrant change request for old registrant' do
    before :all do 
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @new_registrant = Fabricate(:registrant, email: 'test@example.org')
      @domain = Fabricate(:domain, registrant: @registrant)
      @domain.deliver_emails = true
      @domain.registrant_verification_token = '123'
      @domain.registrant_verification_asked_at = Time.zone.now
      @domain.registrant = @new_registrant
      @mail = DomainMailer.pending_update_old_registrant_request(@domain)
    end

    it 'should render email subject' do
      @mail.subject.should =~ /registreerija vahetuseks/
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
      @mail.body.encoded.should =~ %r{registrant\/domain_update_confirms}
    end
  end

  describe 'registrant change notification for new registrant' do
    before :all do 
      @registrant = Fabricate(:registrant, email: 'old@example.com')
      @new_registrant = Fabricate(:registrant, email: 'new@example.org')
      @domain = Fabricate(:domain, registrant: @registrant)
      @domain.deliver_emails = true
      @domain.registrant_verification_token = '123'
      @domain.registrant_verification_asked_at = Time.zone.now
      @domain.registrant = @new_registrant
      @mail = DomainMailer.pending_update_new_registrant_notification(@domain)
    end

    it 'should render email subject' do
      @mail.subject.should =~ /protseduur on algatatud/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send confirm email to new registrant email' do
      @mail.to.should == ["new@example.org"]
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /vahendusel on algatatud/
    end
  end

  describe 'domain pending delete notification when delivery turned off' do
    before :all do 
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @domain = Fabricate(:domain, registrant: @registrant)
      @mail = DomainMailer.pending_deleted(@domain)
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

  describe 'email pending delete notification' do
    before :all do 
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @domain = Fabricate(:domain, name: 'delete-pending.ee', registrant: @registrant)
      @domain.deliver_emails = true
      @domain.registrant_verification_token = '123'
      @domain.registrant_verification_asked_at = Time.zone.now
      @mail = DomainMailer.pending_deleted(@domain)
    end

    it 'should render email subject' do
      @mail.subject.should =~ /kustutamiseks .ee registrist/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send confirm email to old registrant email' do
      @mail.to.should == ["test@example.com"]
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /Registrisse laekus taotlus domeeni delete-pending.ee kustutamiseks/
    end

    it 'should render verification url' do
      @mail.body.encoded.should =~ %r{registrant\/domain_delete_con} # somehowe delete_confirms not matching
    end
  end

  describe 'registrant successfully changed confirmation' do
    before :all do 
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @domain = Fabricate(:domain, registrant: @registrant)
      @domain.deliver_emails = true
      @mail = DomainMailer.registrant_updated(@domain)
    end

    it 'should render email subject' do
      @mail.subject.should =~ /registreerija vahetus teostatud/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send to registrant email' do
      @mail.to.should == ["test@example.com"]
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /registreerija vahetuse taotlus on kinnitatud/
    end
  end
end
