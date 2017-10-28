require 'rails_helper'

RSpec.describe DomainCron do
  it 'should expire domains' do
    create(:zone, origin: 'ee')
    @domain = create(:domain)

    Setting.expire_warning_period = 1
    Setting.redemption_grace_period = 1

    described_class.start_expire_period
    @domain.statuses.include?(DomainStatus::EXPIRED).should == false

    old_valid_to = Time.zone.now - 10.days
    @domain.valid_to = old_valid_to
    @domain.save

    described_class.start_expire_period
    @domain.reload
    @domain.statuses.include?(DomainStatus::EXPIRED).should == true

    described_class.start_expire_period
    @domain.reload
    @domain.statuses.include?(DomainStatus::EXPIRED).should == true
  end

  it 'should start redemption grace period' do
    create(:zone, origin: 'ee')
    @domain = create(:domain)

    old_valid_to = Time.zone.now - 10.days
    @domain.valid_to = old_valid_to
    @domain.statuses = [DomainStatus::EXPIRED]
    @domain.outzone_at, @domain.delete_at = nil, nil
    @domain.save

    described_class.start_expire_period
    @domain.reload
    @domain.statuses.include?(DomainStatus::EXPIRED).should == true
  end
end
